# batch account
resource "azurerm_batch_account" "this" {
  resource_group_name = coalesce(
    var.batch.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.batch.location, var.location
  )

  name                                = var.batch.name
  pool_allocation_mode                = var.batch.pool_allocation_mode
  public_network_access_enabled       = var.batch.public_network_access_enabled
  allowed_authentication_modes        = var.batch.allowed_authentication_modes
  storage_account_id                  = var.batch.storage_account_id
  storage_account_authentication_mode = var.batch.storage_account_authentication_mode
  storage_account_node_identity       = var.batch.storage_account_node_identity

  tags = coalesce(
    var.batch.tags, var.tags
  )

  dynamic "identity" {
    for_each = var.batch.identity != null ? { "this" = var.batch.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.batch.encryption != null ? { "this" = var.batch.encryption } : {}

    content {
      key_vault_key_id = encryption.value.key_vault_key_id
    }
  }

  dynamic "key_vault_reference" {
    for_each = var.batch.key_vault_reference != null ? { "this" = var.batch.key_vault_reference } : {}

    content {
      id  = key_vault_reference.value.id
      url = key_vault_reference.value.url
    }
  }

  dynamic "network_profile" {
    for_each = var.batch.network_profile != null ? { "this" = var.batch.network_profile } : {}

    content {
      dynamic "account_access" {
        for_each = network_profile.value.account_access != null ? { "this" = network_profile.value.account_access } : {}

        content {
          default_action = account_access.value.default_action

          dynamic "ip_rule" {
            for_each = account_access.value.ip_rule

            content {
              ip_range = ip_rule.value.ip_range
              action   = ip_rule.value.action
            }
          }
        }
      }

      dynamic "node_management_access" {
        for_each = network_profile.value.node_management_access != null ? { "this" = network_profile.value.node_management_access } : {}

        content {
          default_action = node_management_access.value.default_action

          dynamic "ip_rule" {
            for_each = node_management_access.value.ip_rule

            content {
              ip_range = ip_rule.value.ip_range
              action   = ip_rule.value.action
            }
          }
        }
      }
    }
  }
}

# private endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.batch.private_endpoints != null ? var.batch.private_endpoints : {}

  resource_group_name = coalesce(
    var.batch.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.batch.location, var.location
  )

  name = coalesce(
    each.value.name, each.key
  )

  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.custom_network_interface_name
  edge_zone                     = each.value.edge_zone

  tags = coalesce(
    each.value.tags, var.tags
  )

  private_service_connection {
    name = coalesce(
      each.value.private_service_connection_name, "${each.key}-connection"
    )

    is_manual_connection              = each.value.is_manual_connection
    private_connection_resource_id    = each.value.private_connection_resource_alias != null ? null : azurerm_batch_account.this.id
    private_connection_resource_alias = each.value.private_connection_resource_alias
    subresource_names                 = each.value.subresource_name != null ? [each.value.subresource_name] : ["batchAccount"]
    request_message                   = each.value.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_resource_ids != null ? { "this" = each.value.private_dns_zone_resource_ids } : {}

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }
}

# batch application
resource "azurerm_batch_application" "this" {
  for_each = var.batch.applications

  name = coalesce(
    each.value.name, replace(each.key, "_", "-")
  )

  resource_group_name = coalesce(
    var.batch.resource_group_name, var.resource_group_name
  )

  account_name    = azurerm_batch_account.this.name
  allow_updates   = each.value.allow_updates
  default_version = each.value.default_version
  display_name    = each.value.display_name
}

# batch pool
resource "azurerm_batch_pool" "this" {
  for_each = var.batch.pools

  name = coalesce(
    each.value.name, replace(each.key, "_", "-")
  )

  resource_group_name = coalesce(
    var.batch.resource_group_name, var.resource_group_name
  )

  account_name                   = azurerm_batch_account.this.name
  vm_size                        = each.value.vm_size
  node_agent_sku_id              = each.value.node_agent_sku_id
  display_name                   = each.value.display_name
  inter_node_communication       = each.value.inter_node_communication
  license_type                   = each.value.license_type
  max_tasks_per_node             = each.value.max_tasks_per_node
  metadata                       = each.value.metadata
  os_disk_placement              = each.value.os_disk_placement
  stop_pending_resize_operation  = each.value.stop_pending_resize_operation
  target_node_communication_mode = each.value.target_node_communication_mode

  dynamic "identity" {
    for_each = each.value.identity != null ? { "this" = each.value.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "auto_scale" {
    for_each = each.value.auto_scale != null ? { "this" = each.value.auto_scale } : {}

    content {
      formula             = auto_scale.value.formula
      evaluation_interval = auto_scale.value.evaluation_interval
    }
  }

  dynamic "fixed_scale" {
    for_each = each.value.fixed_scale != null ? { "this" = each.value.fixed_scale } : {}

    content {
      node_deallocation_method  = fixed_scale.value.node_deallocation_method
      resize_timeout            = fixed_scale.value.resize_timeout
      target_dedicated_nodes    = fixed_scale.value.target_dedicated_nodes
      target_low_priority_nodes = fixed_scale.value.target_low_priority_nodes
    }
  }

  dynamic "storage_image_reference" {
    for_each = each.value.storage_image_reference != null ? { "this" = each.value.storage_image_reference } : {}

    content {
      id        = storage_image_reference.value.id
      offer     = storage_image_reference.value.offer
      publisher = storage_image_reference.value.publisher
      sku       = storage_image_reference.value.sku
      version   = storage_image_reference.value.version
    }
  }

  dynamic "container_configuration" {
    for_each = each.value.container_configuration != null ? { "this" = each.value.container_configuration } : {}

    content {
      type                  = container_configuration.value.type
      container_image_names = container_configuration.value.container_image_names
      container_registries  = container_configuration.value.container_registries
    }
  }

  dynamic "node_placement" {
    for_each = each.value.node_placement != null ? { "this" = each.value.node_placement } : {}

    content {
      policy = node_placement.value.policy
    }
  }

  dynamic "task_scheduling_policy" {
    for_each = each.value.task_scheduling_policy != null ? { "this" = each.value.task_scheduling_policy } : {}

    content {
      node_fill_type = task_scheduling_policy.value.node_fill_type
    }
  }

  dynamic "security_profile" {
    for_each = each.value.security_profile != null ? { "this" = each.value.security_profile } : {}

    content {
      host_encryption_enabled = security_profile.value.host_encryption_enabled
      secure_boot_enabled     = security_profile.value.secure_boot_enabled
      security_type           = security_profile.value.security_type
      vtpm_enabled            = security_profile.value.vtpm_enabled
    }
  }

  dynamic "windows" {
    for_each = each.value.windows != null ? { "this" = each.value.windows } : {}

    content {
      enable_automatic_updates = windows.value.enable_automatic_updates
    }
  }

  dynamic "network_configuration" {
    for_each = each.value.network_configuration != null ? { "this" = each.value.network_configuration } : {}

    content {
      accelerated_networking_enabled   = network_configuration.value.accelerated_networking_enabled
      dynamic_vnet_assignment_scope    = network_configuration.value.dynamic_vnet_assignment_scope
      public_address_provisioning_type = network_configuration.value.public_address_provisioning_type
      public_ips                       = network_configuration.value.public_ips
      subnet_id                        = network_configuration.value.subnet_id

      dynamic "endpoint_configuration" {
        for_each = network_configuration.value.endpoint_configuration

        content {
          name                = coalesce(endpoint_configuration.value.name, replace(endpoint_configuration.key, "_", "-"))
          backend_port        = endpoint_configuration.value.backend_port
          frontend_port_range = endpoint_configuration.value.frontend_port_range
          protocol            = endpoint_configuration.value.protocol

          dynamic "network_security_group_rules" {
            for_each = endpoint_configuration.value.network_security_group_rules

            content {
              access                = network_security_group_rules.value.access
              priority              = network_security_group_rules.value.priority
              source_address_prefix = network_security_group_rules.value.source_address_prefix
              source_port_ranges    = network_security_group_rules.value.source_port_ranges
            }
          }
        }
      }
    }
  }

  dynamic "start_task" {
    for_each = each.value.start_task != null ? { "this" = each.value.start_task } : {}

    content {
      command_line                  = start_task.value.command_line
      common_environment_properties = start_task.value.common_environment_properties
      task_retry_maximum            = start_task.value.task_retry_maximum
      wait_for_success              = start_task.value.wait_for_success

      dynamic "container" {
        for_each = start_task.value.container != null ? { "this" = start_task.value.container } : {}

        content {
          image_name        = container.value.image_name
          run_options       = container.value.run_options
          working_directory = container.value.working_directory

          dynamic "registry" {
            for_each = container.value.registry

            content {
              registry_server           = registry.value.registry_server
              user_name                 = registry.value.user_name
              password                  = registry.value.password
              user_assigned_identity_id = registry.value.user_assigned_identity_id
            }
          }
        }
      }

      dynamic "user_identity" {
        for_each = start_task.value.user_identity != null ? { "this" = start_task.value.user_identity } : {}

        content {
          user_name = user_identity.value.user_name

          dynamic "auto_user" {
            for_each = user_identity.value.auto_user != null ? { "this" = user_identity.value.auto_user } : {}

            content {
              elevation_level = auto_user.value.elevation_level
              scope           = auto_user.value.scope
            }
          }
        }
      }

      dynamic "resource_file" {
        for_each = start_task.value.resource_file

        content {
          auto_storage_container_name = resource_file.value.auto_storage_container_name
          blob_prefix                 = resource_file.value.blob_prefix
          file_mode                   = resource_file.value.file_mode
          file_path                   = resource_file.value.file_path
          http_url                    = resource_file.value.http_url
          storage_container_url       = resource_file.value.storage_container_url
          user_assigned_identity_id   = resource_file.value.user_assigned_identity_id
        }
      }
    }
  }

  dynamic "data_disks" {
    for_each = each.value.data_disks

    content {
      disk_size_gb         = data_disks.value.disk_size_gb
      lun                  = data_disks.value.lun
      caching              = data_disks.value.caching
      storage_account_type = data_disks.value.storage_account_type
    }
  }

  dynamic "disk_encryption" {
    for_each = each.value.disk_encryption

    content {
      disk_encryption_target = disk_encryption.value.disk_encryption_target
    }
  }

  dynamic "extensions" {
    for_each = each.value.extensions

    content {
      name = coalesce(
        extensions.value.name, replace(extensions.key, "_", "-")
      )

      publisher                  = extensions.value.publisher
      type                       = extensions.value.type
      auto_upgrade_minor_version = extensions.value.auto_upgrade_minor_version
      automatic_upgrade_enabled  = extensions.value.automatic_upgrade_enabled
      protected_settings         = extensions.value.protected_settings
      provision_after_extensions = extensions.value.provision_after_extensions
      settings_json              = extensions.value.settings_json
      type_handler_version       = extensions.value.type_handler_version
    }
  }

  dynamic "mount" {
    for_each = each.value.mount

    content {
      dynamic "azure_blob_file_system" {
        for_each = mount.value.azure_blob_file_system != null ? { "this" = mount.value.azure_blob_file_system } : {}

        content {
          account_name        = azure_blob_file_system.value.account_name
          container_name      = azure_blob_file_system.value.container_name
          relative_mount_path = azure_blob_file_system.value.relative_mount_path
          account_key         = azure_blob_file_system.value.account_key
          blobfuse_options    = azure_blob_file_system.value.blobfuse_options
          identity_id         = azure_blob_file_system.value.identity_id
          sas_key             = azure_blob_file_system.value.sas_key
        }
      }

      dynamic "azure_file_share" {
        for_each = mount.value.azure_file_share != null ? { "this" = mount.value.azure_file_share } : {}

        content {
          account_name        = azure_file_share.value.account_name
          account_key         = azure_file_share.value.account_key
          azure_file_url      = azure_file_share.value.azure_file_url
          relative_mount_path = azure_file_share.value.relative_mount_path
          mount_options       = azure_file_share.value.mount_options
        }
      }

      dynamic "cifs_mount" {
        for_each = mount.value.cifs_mount != null ? { "this" = mount.value.cifs_mount } : {}

        content {
          user_name           = cifs_mount.value.user_name
          password            = cifs_mount.value.password
          source              = cifs_mount.value.source
          relative_mount_path = cifs_mount.value.relative_mount_path
          mount_options       = cifs_mount.value.mount_options
        }
      }

      dynamic "nfs_mount" {
        for_each = mount.value.nfs_mount != null ? { "this" = mount.value.nfs_mount } : {}

        content {
          source              = nfs_mount.value.source
          relative_mount_path = nfs_mount.value.relative_mount_path
          mount_options       = nfs_mount.value.mount_options
        }
      }
    }
  }

  dynamic "user_accounts" {
    for_each = each.value.user_accounts

    content {
      name = coalesce(
        user_accounts.value.name, replace(user_accounts.key, "_", "-")
      )

      elevation_level = user_accounts.value.elevation_level
      password        = user_accounts.value.password

      dynamic "linux_user_configuration" {
        for_each = user_accounts.value.linux_user_configuration != null ? { "this" = user_accounts.value.linux_user_configuration } : {}

        content {
          gid             = linux_user_configuration.value.gid
          uid             = linux_user_configuration.value.uid
          ssh_private_key = linux_user_configuration.value.ssh_private_key
        }
      }

      dynamic "windows_user_configuration" {
        for_each = user_accounts.value.windows_user_configuration != null ? { "this" = user_accounts.value.windows_user_configuration } : {}

        content {
          login_mode = windows_user_configuration.value.login_mode
        }
      }
    }
  }
}

# batch job
resource "azurerm_batch_job" "this" {
  for_each = merge([
    for pool_key, pool in(var.batch.pools != null ? var.batch.pools : {}) : {
      for job_key, job in(pool.jobs != null ? pool.jobs : {}) :
      "${pool_key}-${job_key}" => merge(job, { pool_key = pool_key, job_key = job_key })
    }
  ]...)

  name = coalesce(
    each.value.name, replace(each.value.job_key, "_", "-")
  )

  batch_pool_id                 = azurerm_batch_pool.this[each.value.pool_key].id
  display_name                  = each.value.display_name
  priority                      = each.value.priority
  task_retry_maximum            = each.value.task_retry_maximum
  common_environment_properties = each.value.common_environment_properties

  depends_on = [azurerm_private_endpoint.this]
}
