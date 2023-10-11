terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "TaskBoardRG12-6775"
    storage_account_name = "taskboardstorage31"
    container_name = "taskboardcontainer"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "random_integer" "unique_id" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${random_integer.unique_id.result}"
  location = var.resource_group_location
}

resource "azurerm_app_service_plan" "app" {
  name                = "${var.app_service_plan_name}-${random_integer.unique_id.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.app_service_name}-${random_integer.unique_id.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.app.id

  site_config {
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_sql_server.rg.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.rg.name};User ID=${var.sql_admin_login};Password=${var.sql_admin_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "examplesataskborg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_server" "rg" {
  name                         = "${var.sql_server_name}-${random_integer.unique_id.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_database" "rg" {
  name                = "${var.sql_database_name}-${random_integer.unique_id.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.rg.name

  tags = {
    environment = "production"
  }
}

resource "azurerm_sql_firewall_rule" "rg" {
  name                = "${var.firewall_rule_name}-${random_integer.unique_id.result}"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.rg.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_app_service_source_control" "app" {
  app_id                 = azurerm_linux_web_app.app.id
  repo_url               = var.repo_URL
  branch                 = "master"
  use_manual_integration = true
}
