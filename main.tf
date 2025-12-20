
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  ROUTE TABLE | PUBLIC PRIVATE, DATABASE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

locals {
  # Local will act as generic input for flatten_map_route_table to create PUB-RT
  GENERIC_PUBLIC_RT = {
    (local.PUBLIC_SHORTENED) = {
      tier   = local.PUBLIC
      rt_key = "all"
    }
  }
  flatten_map_route_table = merge(local.GENERIC_PUBLIC_RT, [
    for tier, azs in try(local.network.active_azs, {}) : {
      # Example: { PUB-1A : { ... }, { PRV-1B : {...} } }
      # Note: This key will be referenced at local.flatten_map_route_table_associations
      for az in azs : format("%s-%s", local.TIER_DICTIONARY[tier], az) => {
        tier   = tier
        rt_key = az
      }
    }
    # Public is not included since it will only have 1 RT
    if tier != local.PUBLIC
  ]...)
}

# Create Route Tables
resource "aws_route_table" "this" {
  for_each = local.flatten_map_route_table

  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, each.key)
  })
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  ROUTE TABLE - Associations
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_route_table_association" "this" {
  for_each = local.flatten_map_route_table_associations

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.this[each.value.rt_key].id
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  NACL - Associations | PUBLIC PRIVATE, DATABASE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

locals {
  all_nacl_associations = merge([
    for tier in local.TIER_LIST : {
      for key, nacl in try(local.nacls[tier], {}) :
      format("%s-%s", local.TIER_DICTIONARY[tier], key) => {
        nacl_id   = nacl.id
        subnet_id = local.subnets[tier][key].id
      }
    }
  ]...)
}

resource "aws_network_acl_association" "this" {
  for_each = local.all_nacl_associations

  network_acl_id = each.value.nacl_id
  subnet_id      = each.value.subnet_id
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  NACL - Associations | SHARED NACLS
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_network_acl_association" "shared" {
  for_each = local.map_shared_nacl_associations

  network_acl_id = local.nacls_shared[each.value.nacl_key].id
  subnet_id      = local.subnets[each.value.tier][each.value.subnet_key].id
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# NACL - Associations | QUARANTINE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
locals {
  map_quarantine_nacl_association = merge([
    for tier, subnet_keys in var.quarantine_subnets : {
      for key in subnet_keys :
      format("%s-%s", local.TIER_DICTIONARY[tier], key) => {
        tier       = tier
        nacl_key   = local.QUARANTINE
        subnet_key = key
      }
    }
  ]...)
}

resource "aws_network_acl_association" "quarantine" {
  for_each = local.map_quarantine_nacl_association

  network_acl_id = local.nacls_shared[each.value.nacl_key].id
  subnet_id      = local.subnets[each.value.tier][each.value.subnet_key].id
}
