variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "Service plan name in Azure"
}

variable "app_service_name" {
  type        = string
  description = "Service name in Azure"
}

variable "sql_server_name" {
  type        = string
  description = "Server name in SQL"
}

variable "sql_database_name" {
  type        = string
  description = "Database name in SQL"
}

variable "sql_admin_login" {
  type        = string
  description = "Admin login in SQL"
}

variable "sql_admin_password" {
  type        = string
  description = "Admin password in SQL"
}

variable "firewall_rule_name" {
  type        = string
  description = "Rule name for firewall"
}

variable "repo_URL" {
  type        = string
  description = "URL of the repo"
}