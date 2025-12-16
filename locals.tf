locals {

  namespace = upper(format("%s-%s", var.namespace, var.env))

  # Load network state from either local or remote based on provided variables
  # S3 Bucket and Key takes precedence over local path
  network = data.terraform_remote_state.remote == null ? data.terraform_remote_state.local[0].outputs : data.terraform_remote_state.remote[0].outputs


  map_active_azs        = local.network.active_azs
  list_nat_gateway_keys = keys(local.network.nat_gateways)

  # Routes -------------------------------------------------------------------------------------------------
  # NAT Access 
  list_private_rt_nat_access  = var.enable_nat_access_to_all_private_subnets ? local.list_nat_gateway_keys : var.set_private_subnet_nat_az_connection
  list_database_rt_nat_access = var.enable_nat_access_to_all_database_subnets ? local.list_nat_gateway_keys : var.set_database_subnet_nat_az_connection
  #----------------------------------------------------------------------------------------------------------------------------------------------------------

  # Route table association locals -------------------------------------------------------------------------------------------------------------------------
  # Merge subnets to simplify logic in excluding isolated and quarantined subnets
  merged_raw_subnets = {
    (local.PUBLIC_SUBNETS)   = local.network[local.PUBLIC_SUBNETS],
    (local.PRIVATE_SUBNETS)  = local.network[local.PRIVATE_SUBNETS],
    (local.DATABASE_SUBNETS) = local.network[local.DATABASE_SUBNETS]
  }

  # Get every unique tier name from BOTH variables
  # Result: ["public_subnets", "private_subnets"]
  all_tiers = setunion(keys(var.isolate_subnets), keys(var.quarantine_subnets))

  # Loop through the combined list of keys
  map_isolated_subnets = {
    for tier in local.all_tiers : tier => setunion(
      try(var.isolate_subnets[tier], []),
      try(var.quarantine_subnets[tier], [])
    )
  }

  map_route_table_associations = {
    # OUTER LOOP: Iterates through "public_subnets", "private_subnets"
    for tier_name, subnet_map in local.merged_raw_subnets : tier_name => {

      # INNER LOOP: Iterates through "1A1", "1B1" inside that tier
      for az_key, subnet_details in subnet_map : az_key => subnet_details

      # THE CONDITION: 
      # Check if the isolation list for this tier (e.g., "private_subnets") 
      # contains this specific key (e.g., "1A1")
      if !contains(try(local.map_isolated_subnets[tier_name], []), az_key)
    }
  }

}