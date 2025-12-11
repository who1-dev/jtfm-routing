locals {

  namespace = upper(format("%s-%s", var.namespace, var.env))

  # Load network state from either local or remote based on provided variables
  # S3 Bucket and Key takes precedence over local path
  network   = data.terraform_remote_state.remote == null ? data.terraform_remote_state.local[0].outputs : data.terraform_remote_state.remote[0].outputs


  list_nat_gateway_keys = [for key, details in local.network.nat_gateways : key]


  # Create keys for route table by getting the first 2 string(AZ) e.g 1A1, 1A2, 1B1 = 1A, 1B-----------------------------------------
  list_private_az_keys = distinct([
    for k in keys(local.network.private_subnets) : upper(substr(k, 0, 2))
  ])

  list_database_az_keys = distinct([
    for k in keys(local.network.database_subnets) : upper(substr(k, 0, 2))
  ])
  #----------------------------------------------------------------------------------------------------------------------------------------------------------


  # Route table association lists -------------------------------------------------------------------------------------------------------------------------
  list_public_subnet = length(var.exclude_public_subnet) == 0 ? local.network.public_subnets : { for k, v in local.network.public_subnets :
    k => v if !contains(var.exclude_public_subnet, k)
  }

  list_private_subnet = length(var.exclude_private_subnet) == 0 ? local.network.private_subnets : { for k, v in local.network.private_subnets :
    k => v if !contains(var.exclude_private_subnet, k)
  }

  list_database_subnet = length(var.exclude_database_subnet) == 0 ? local.network.database_subnets : { for k, v in local.network.database_subnets :
    k => v if !contains(var.exclude_database_subnet, k)
  }
  #----------------------------------------------------------------------------------------------------------------------------------------------------------


  # Routes -------------------------------------------------------------------------------------------------
  list_private_rt_nat_access  = var.enable_nat_access_to_all_private_subnets ? local.list_nat_gateway_keys : var.set_private_subnet_nat_az_connection
  list_database_rt_nat_access = var.enable_nat_access_to_all_database_subnets ? local.list_nat_gateway_keys : var.set_database_subnet_nat_az_connection
  #----------------------------------------------------------------------------------------------------------------------------------------------------------


}