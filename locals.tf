locals {

  namespace = format("%s-%s", var.namespace, var.env)

  # Load network state from either local or remote based on provided variables
  # S3 Bucket and Key takes precedence over local path
  network = data.terraform_remote_state.remote == null ? data.terraform_remote_state.local[0].outputs : data.terraform_remote_state.remote[0].outputs

  subnets      = try(local.network[local.SUBNETS])
  nacls        = try(local.network[local.NACLS], {})
  nacls_shared = try(local.nacls[local.SHARED], {})

  # Used as source of truth for NAT Gateway AZ connections
  map_active_azs = try(local.network.active_azs, {})


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

  # The flattened map
  flatten_map_route_table_associations = merge([
    for tier, subnet_map in local.subnets : {
      for subnet_key, subnet_details in subnet_map :
      # Example: { PUB-1A1 : { ... }, { PRV-1B1 : {...} } }
      "${local.TIER_DICTIONARY[tier]}-${subnet_key}" => {
        subnet_id = subnet_details.id
        rt_key    = (tier == local.PUBLIC) ? local.TIER_DICTIONARY[tier] : format("%s-%s", local.TIER_DICTIONARY[tier], subnet_details.short_az)
        tier      = tier
      }
      # Remove RT Association for isolated subnets.
      if !contains(try(local.map_isolated_subnets[tier], []), subnet_key)
    }
  ]...)

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

  map_shared_nacl_associations = {
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