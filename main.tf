locals {
  resource_group_name  = coalesce(var.resource_group_name, lookup(var.defaults, "resource_group_name", "unspecified"))
  location             = coalesce(var.location, var.defaults.location)
  tags                 = merge(lookup(var.defaults, "tags", {}), var.tags)
  boot_diagnostics_uri = coalesce(var.boot_diagnostics_uri, var.defaults.boot_diagnostics_uri)
  admin_username       = coalesce(var.admin_username, var.defaults.admin_username, "ubuntu")
  admin_ssh_public_key = try(coalesce(var.admin_ssh_public_key, var.defaults.admin_ssh_public_key), file("~/.ssh/id_rsa.pub"))
  additional_ssh_keys  = try(coalesce(var.additional_ssh_keys, var.defaults.additional_ssh_keys), [])
  subnet_id            = coalesce(var.subnet_id, var.defaults.subnet_id)
  vm_size              = coalesce(var.vm_size, var.defaults.vm_size, "Standard_B1ls")
  identity_id          = try(coalesce(var.identity_id, var.defaults.identity_id), null)
  storage_account_type = coalesce(var.storage_account_type, var.defaults.storage_account_type, "Standard_LRS")
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = local.tags
  depends_on          = [var.module_depends_on]

  sku                          = local.vm_size
  instances                    = var.instances
  proximity_placement_group_id = var.proximity_placement_group_id
  // zones                        = ["1", "2", "3"]

  lifecycle {
    ignore_changes = [
      instances,
    ]
  }

  admin_username = local.admin_username

  admin_ssh_key {
    username   = local.admin_username
    public_key = local.admin_ssh_public_key
  }

  source_image_id = var.source_image_id


  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "primary-nic"
    primary                       = true
    enable_accelerated_networking = false
    network_security_group_id     = null

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = local.subnet_id

      application_gateway_backend_address_pool_ids = var.application_gateway_backend_address_pool_ids
      load_balancer_backend_address_pool_ids       = var.load_balancer_backend_address_pool_ids
      application_security_group_ids               = var.application_security_group_ids
    }
  }

  upgrade_mode = "Manual"

  //
  // health_probe_id = local.application_gateway_probe_id["Https"]
  //
  // automatic_instance_repair {
  //   enabled = true
  // }

  boot_diagnostics {
    storage_account_uri = local.boot_diagnostics_uri
  }

  dynamic "identity" {
    for_each = toset(local.identity_id != null ? [1] : [])

    content {
      type         = "UserAssigned"
      identity_ids = [local.identity_id]
    }
  }

  dynamic "identity" {
    for_each = toset(local.identity_id == null ? [1] : [])

    content {
      type = "SystemAssigned"
    }
  }
}

/*
THIS NEEDS VARIABLES AND TESTING FOR SUCCESSFUL AUTOSCALING
HAVE A SET OF THESE AND A VARIABLE TO CHOOSE - PERHAPS SPLIT E.G. CPU-75-25

resource "azurerm_monitor_autoscale_setting" "pool3" {
  name                = "autoscale-config"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_pool3.id
  depends_on          = [azurerm_linux_virtual_machine_scale_set.web_pool3]

  profile {
    name = "AutoScale"

    capacity {
      default = 2
      minimum = 1
      maximum = 6
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_pool3.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_pool3.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  // notification {
  //   email {
  //     send_to_subscription_administrator    = true
  //     send_to_subscription_co_administrator = true
  //     custom_emails                         = ["admin@contoso.com"]
  //   }
  // }
}
*/
