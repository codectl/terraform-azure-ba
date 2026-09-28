# Batch

This terraform module simplifies the creation and management of azure batch resources, providing customizable options for batch accounts, applications, pools and jobs, all managed through code.

## Features

Manages an azure batch account as the primary resource.

Capability to handle batch applications, pools and jobs.

Supports pool configuration including scaling, container workloads, mounts, start tasks and node networking.

Supports private endpoints for the batchAccount and nodeManagement subresources.

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 5.0)

## Resources

The following resources are used by this module:

- [azurerm_batch_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_account) (resource)
- [azurerm_batch_application.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_application) (resource)
- [azurerm_batch_job.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_job) (resource)
- [azurerm_batch_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/batch_pool) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_batch"></a> [batch](#input\_batch)

Description: describes batch account related configuration

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_applications"></a> [applications](#output\_applications)

Description: contains all batch applications

### <a name="output_batch"></a> [batch](#output\_batch)

Description: contains all batch account configuration

### <a name="output_jobs"></a> [jobs](#output\_jobs)

Description: contains all batch jobs

### <a name="output_pools"></a> [pools](#output\_pools)

Description: contains all batch pools

### <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints)

Description: contains all batch private endpoints
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make docs`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-ba/graphs/contributors).

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-ba/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-ba" />
</a>

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-ba/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/batch/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/batchmanagement/)
