module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["apps", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "northeurope"
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

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "batch" {
  source  = "codectl/ba/azure"
  version = "~> 1.0"

  batch = {
    name                = module.naming.batch_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    storage_account_id                  = module.storage.account.id
    storage_account_authentication_mode = "StorageKeys"

    applications = {
      app1 = {
        display_name  = "demo-application"
        allow_updates = true
      }
    }
  }
}
