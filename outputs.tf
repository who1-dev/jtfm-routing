output "mapper" {
  description = "Mapper of created resources"
  value       = local.network
}

output "keys" {
  value = {
    private = local.list_private_az_keys
  }
}
