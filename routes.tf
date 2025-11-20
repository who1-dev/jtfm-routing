resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = local.network.igw_id
}

resource "aws_route" "private_nat_access" {
  for_each = toset(local.list_private_rt_nat_access)

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = local.network.nat_gateways[each.key].id
}

resource "aws_route" "database_nat_access" {
  for_each = toset(local.list_database_rt_nat_access)

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = local.network.nat_gateways[each.key].id
}