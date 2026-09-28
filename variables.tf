variable "batch" {
  description = "describes batch account related configuration"
  type = object({
    name                                = string
    location                            = optional(string)
    resource_group_name                 = optional(string)
    tags                                = optional(map(string))
    pool_allocation_mode                = optional(string)
    public_network_access_enabled       = optional(bool)
    allowed_authentication_modes        = optional(set(string))
    storage_account_id                  = optional(string)
    storage_account_authentication_mode = optional(string)
    storage_account_node_identity       = optional(string)
    encryption = optional(object({
      key_vault_key_id = optional(string)
    }))
    identity = optional(object({
      type         = string
      identity_ids = optional(set(string))
    }))
    key_vault_reference = optional(object({
      id  = string
      url = string
    }))
    network_profile = optional(object({
      account_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(map(object({
          ip_range = string
          action   = optional(string)
        })), {})
      }))
      node_management_access = optional(object({
        default_action = optional(string)
        ip_rule = optional(map(object({
          ip_range = string
          action   = optional(string)
        })), {})
      }))
    }))
    private_endpoints = optional(map(object({
      name                              = optional(string)
      subnet_resource_id                = string
      subresource_name                  = optional(string)
      private_dns_zone_resource_ids     = optional(list(string))
      private_dns_zone_group_name       = optional(string, "default")
      custom_network_interface_name     = optional(string)
      edge_zone                         = optional(string)
      tags                              = optional(map(string))
      private_service_connection_name   = optional(string)
      private_connection_resource_alias = optional(string)
      is_manual_connection              = optional(bool, false)
      request_message                   = optional(string)
      ip_configurations = optional(map(object({
        name               = optional(string)
        private_ip_address = optional(string)
        member_name        = optional(string)
        subresource_name   = optional(string)
      })))
    })))
    applications = optional(map(object({
      name            = optional(string)
      allow_updates   = optional(bool)
      default_version = optional(string)
      display_name    = optional(string)
    })), {})
    pools = optional(map(object({
      name                           = optional(string)
      vm_size                        = string
      node_agent_sku_id              = string
      display_name                   = optional(string)
      inter_node_communication       = optional(string)
      license_type                   = optional(string)
      max_tasks_per_node             = optional(number)
      metadata                       = optional(map(string))
      os_disk_placement              = optional(string)
      stop_pending_resize_operation  = optional(bool)
      target_node_communication_mode = optional(string)
      identity = optional(object({
        type         = string
        identity_ids = set(string)
      }))
      auto_scale = optional(object({
        formula             = string
        evaluation_interval = optional(string)
      }))
      fixed_scale = optional(object({
        node_deallocation_method  = optional(string)
        resize_timeout            = optional(string)
        target_dedicated_nodes    = optional(number)
        target_low_priority_nodes = optional(number)
      }))
      storage_image_reference = optional(object({
        id        = optional(string)
        offer     = optional(string)
        publisher = optional(string)
        sku       = optional(string)
        version   = optional(string)
      }))
      container_configuration = optional(object({
        type                  = optional(string)
        container_image_names = optional(set(string))
        container_registries = optional(list(object({
          registry_server           = string
          user_name                 = optional(string)
          password                  = optional(string)
          user_assigned_identity_id = optional(string)
        })))
      }))
      node_placement = optional(object({
        policy = optional(string)
      }))
      task_scheduling_policy = optional(object({
        node_fill_type = optional(string)
      }))
      security_profile = optional(object({
        host_encryption_enabled = optional(bool)
        secure_boot_enabled     = optional(bool)
        security_type           = optional(string)
        vtpm_enabled            = optional(bool)
      }))
      windows = optional(object({
        enable_automatic_updates = optional(bool)
      }))
      network_configuration = optional(object({
        accelerated_networking_enabled   = optional(bool)
        dynamic_vnet_assignment_scope    = optional(string)
        public_address_provisioning_type = optional(string)
        public_ips                       = optional(set(string))
        subnet_id                        = optional(string)
        endpoint_configuration = optional(map(object({
          name                = optional(string)
          backend_port        = number
          frontend_port_range = string
          protocol            = string
          network_security_group_rules = optional(map(object({
            access                = string
            priority              = number
            source_address_prefix = string
            source_port_ranges    = optional(list(string))
          })), {})
        })), {})
      }))
      start_task = optional(object({
        command_line                  = string
        common_environment_properties = optional(map(string))
        task_retry_maximum            = optional(number)
        wait_for_success              = optional(bool)
        container = optional(object({
          image_name        = string
          run_options       = optional(string)
          working_directory = optional(string)
          registry = optional(map(object({
            registry_server           = string
            user_name                 = optional(string)
            password                  = optional(string)
            user_assigned_identity_id = optional(string)
          })), {})
        }))
        user_identity = optional(object({
          user_name = optional(string)
          auto_user = optional(object({
            elevation_level = optional(string)
            scope           = optional(string)
          }))
        }))
        resource_file = optional(map(object({
          auto_storage_container_name = optional(string)
          blob_prefix                 = optional(string)
          file_mode                   = optional(string)
          file_path                   = optional(string)
          http_url                    = optional(string)
          storage_container_url       = optional(string)
          user_assigned_identity_id   = optional(string)
        })), {})
      }))
      data_disks = optional(map(object({
        disk_size_gb         = number
        lun                  = number
        caching              = optional(string)
        storage_account_type = optional(string)
      })), {})
      disk_encryption = optional(map(object({
        disk_encryption_target = string
      })), {})
      extensions = optional(map(object({
        name                       = optional(string)
        publisher                  = string
        type                       = string
        auto_upgrade_minor_version = optional(bool)
        automatic_upgrade_enabled  = optional(bool)
        protected_settings         = optional(string)
        provision_after_extensions = optional(set(string))
        settings_json              = optional(string)
        type_handler_version       = optional(string)
      })), {})
      mount = optional(map(object({
        azure_blob_file_system = optional(object({
          account_name        = string
          container_name      = string
          relative_mount_path = string
          account_key         = optional(string)
          blobfuse_options    = optional(string)
          identity_id         = optional(string)
          sas_key             = optional(string)
        }))
        azure_file_share = optional(object({
          account_name        = string
          account_key         = string
          azure_file_url      = string
          relative_mount_path = string
          mount_options       = optional(string)
        }))
        cifs_mount = optional(object({
          user_name           = string
          password            = string
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        }))
        nfs_mount = optional(object({
          source              = string
          relative_mount_path = string
          mount_options       = optional(string)
        }))
      })), {})
      user_accounts = optional(map(object({
        name            = optional(string)
        elevation_level = string
        password        = string
        linux_user_configuration = optional(object({
          gid             = optional(number)
          uid             = optional(number)
          ssh_private_key = optional(string)
        }))
        windows_user_configuration = optional(object({
          login_mode = string
        }))
      })), {})
      jobs = optional(map(object({
        name                          = optional(string)
        display_name                  = optional(string)
        priority                      = optional(number)
        task_retry_maximum            = optional(number)
        common_environment_properties = optional(map(string))
      })))
    })), {})
  })

  validation {
    condition     = var.batch.location != null || var.location != null
    error_message = "location must be set on var.batch.location or on the module-level var.location."
  }

  validation {
    condition     = var.batch.resource_group_name != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.batch.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
