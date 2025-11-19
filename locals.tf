locals {


  namespace = upper(format("%s-%s-%s", var.namespace, var.env, local.VPC))
  network   = data.terraform_remote_state.network_resources.outputs

  # Create keys for route table by getting the first 2 string(AZ) e.g 1A1, 1A2, 1B1 = 1A, 1B
  list_private_az_keys = distinct([
    for k in keys(local.network.private_subnets) : upper(substr(k, 0, 2))
  ])

  list_database_az_keys = distinct([
    for k in keys(local.network.database_subnets) : upper(substr(k, 0, 2))
  ])


}