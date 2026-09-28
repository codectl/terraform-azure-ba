output "batch" {
  description = "contains all batch account configuration"
  value       = azurerm_batch_account.this
}

output "applications" {
  description = "contains all batch applications"
  value       = azurerm_batch_application.this
}

output "pools" {
  description = "contains all batch pools"
  value       = azurerm_batch_pool.this
  sensitive   = true
}

output "jobs" {
  description = "contains all batch jobs"
  value       = azurerm_batch_job.this
}

output "private_endpoints" {
  description = "contains all batch private endpoints"
  value       = azurerm_private_endpoint.this
}
