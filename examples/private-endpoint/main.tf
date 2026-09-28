module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["pe", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        network_security_group = {}
        address_prefixes       = ["10.19.1.0/24"]
      }
    }
  }
}

module "batch" {
  source  = "cloudnationhq/ba/azure"
  version = "~> 2.0"

  batch = {
    name                = module.naming.batch_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    public_network_access_enabled = false

    private_endpoints = {
      default = {
        name                            = module.naming.private_endpoint.name
        subnet_resource_id              = module.network.subnets.sn1.id
        private_dns_zone_resource_ids   = [module.private_dns.private_zones.batch.id]
        private_service_connection_name = "batch"
        subresource_name                = "batchAccount"
      }
    }
  }
}

module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 5.0"

  resource_group_name = module.rg.groups.demo.name

  zones = {
    private = {
      batch = {
        name = "privatelink.batch.azure.com"
        virtual_network_links = {
          link1 = {
            virtual_network_id   = module.network.vnet.id
            registration_enabled = true
          }
        }
      }
    }
  }
}
