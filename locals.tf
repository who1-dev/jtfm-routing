locals {

  namespace = upper(format("%s-%s", var.namespace, var.env))

  # Load network state from either local or remote based on provided variables
  # S3 Bucket and Key takes precedence over local path
  network = data.terraform_remote_state.remote == null ? data.terraform_remote_state.local[0].outputs : data.terraform_remote_state.remote[0].outputs

  subnets        = try(local.network[local.SUBNETS])
  nacls          = try(local.network[local.NACLS], {})
  nacls_shared   = try(local.nacls[local.SHARED], {})
  map_active_azs = local.network.active_azs


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  #  ROUTE TABLE ASSOCIATIONS
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # Get every unique tier name from BOTH variables
  all_tiers = setunion(keys(var.isolate_subnets), keys(var.quarantine_subnets))

  # Loop through the combined list of keys
  map_isolated_subnets = {
    for tier in local.all_tiers : tier => setunion(
      try(var.isolate_subnets[tier], []),
      try(var.quarantine_subnets[tier], [])
    )
  }

  # Removes subnet_keys that are mentioned from ISOLATE and QUARANTINE
  map_route_table_associations = {
    # OUTER LOOP: Iterates through "public", "private"
    for tier, subnet_map in local.subnets : tier => {

      # INNER LOOP: Iterates through "1A1", "1B1" inside that tier
      for az_key, subnet_details in subnet_map : az_key => subnet_details

      # THE CONDITION: 
      # Check if the isolation list for this tier (e.g., "private_subnets") 
      # contains this specific key (e.g., "1A1")
      if !contains(try(local.map_isolated_subnets[tier], []), az_key)
    }
  }

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  #  ROUTES - NAT Access 
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  list_nat_gateway_keys       = keys(local.network.nat_gateways)
  list_private_rt_nat_access  = var.enable_nat_access_to_all_private_subnets ? local.list_nat_gateway_keys : var.set_private_subnet_nat_az_connection
  list_database_rt_nat_access = var.enable_nat_access_to_all_database_subnets ? local.list_nat_gateway_keys : var.set_database_subnet_nat_az_connection


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  #  NACL - Associations | SHARED NACLS
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # IMPORTANT NOTE: Explicit NACL Subnet creation at network module takes high priority than SHARED NACL.
  # Example : public = ["1A1"] was created and was then mentioned in SHARED_NACL_ASSOCIATIONS. NACLS["1A1"] will be associated

  # Step 1: filtered_shared_nacl_associations |   Remove the Key at SHARED_NACL_ASSOCIATIONS if subnet_key was explicitly created.
  # Step 2: map_nacl_associations             |   Generating the map for SHARED_NACL_ASSOCIATIONS:
  #   Example Input : COMMON_NACL = { public = ["1B1"] }
  #   Example Output: Key will look like this: (NACL-TIER-SUBNET) = { COMMON_NACL-PUB-1B1 }

  filtered_shared_nacl_associations = {
    for nacl_key, details in var.shared_nacl_associations : nacl_key => {
      for tier, subnets in details : tier => setsubtract(
        (subnets == null ? [] : subnets),
        try(keys(local.nacls[tier]), [])
      )
    }
  }

  map_nacl_associations = {
    for item in flatten([
      for nacl_name, tier_map in local.filtered_shared_nacl_associations : [
        for tier, subnets in tier_map : [
          for subnet_key in subnets : {
            nacl_name  = nacl_name
            tier       = tier
            subnet_key = subnet_key
          }
        ]
      ]
    ]) :
    # The Map Logic (Key => Value)
    format("%s-%s-%s", item.nacl_name, local.TIER_DICTIONARY[item.tier], item.subnet_key) => {
      nacl_key   = item.nacl_name
      subnet_key = item.subnet_key
      tier       = item.tier
    }
  }
}