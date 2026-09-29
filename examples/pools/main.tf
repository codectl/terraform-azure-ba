module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["pools", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "uksouth"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "batch" {
  source  = "codectl/ba/azure"
  version = "~> 1.0"

  batch = {
    name                = module.naming.batch_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    pools = {
      linux = {
        vm_size           = "Standard_A1_v2"
        node_agent_sku_id = "batch.node.ubuntu 22.04"

        fixed_scale = {
          target_dedicated_nodes = 1
        }

        storage_image_reference = {
          publisher = "canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }

        start_task = {
          command_line     = "echo 'hello from batch'"
          wait_for_success = true

          user_identity = {
            auto_user = {
              elevation_level = "NonAdmin"
              scope           = "Pool"
            }
          }
        }
      }
    }
  }
}
