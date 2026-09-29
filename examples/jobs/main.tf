module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["jobs", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "francecentral"
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

        jobs = {
          job1 = {
            display_name       = "demo-job"
            priority           = 1
            task_retry_maximum = 2
          }
        }
      }
    }
  }
}
