locals {
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  #  ROUTES - NAT Access 
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  available_natgw = try(local.network.nat_gateways, {})
  natgw_keys      = keys(local.available_natgw)

  map_nat_access = merge([
    for tier, details in var.nat_access : {
      for idx, az in(details.all ? try(local.map_active_azs[tier], []) : details.azs) :
      format("%s-%s", local.TIER_DICTIONARY[tier], az) => {

        # If AZ don't have dedicated NAT Gateway, pick one from available NAT Gateways
        nat_id = local.available_natgw[contains(local.natgw_keys, az) ? az : element(local.natgw_keys, idx)].id
        # Only create if the AZ is active(Active AZs come from the network module)
      } if contains(try(local.map_active_azs[tier], []), az)
    }
  ]...)
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.this[local.PUBLIC_SHORTENED].id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = local.network.igw_id
}

resource "aws_route" "nat_access" {
  for_each = local.map_nat_access

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = each.value.nat_id

}