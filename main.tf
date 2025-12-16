# # Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_RT)
  })
}



# Creates  Private Route Table
resource "aws_route_table" "private" {
  for_each = toset(try(local.map_active_azs[local.PRIVATE], []))

  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PRV_RT, each.key)
  })
}

# Create a Database Route Table
resource "aws_route_table" "database" {
  for_each = toset(try(local.map_active_azs[local.DATABASE], []))

  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_RT, each.key)
  })
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each       = local.map_route_table_associations[local.PUBLIC_SUBNETS]
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each = local.map_route_table_associations[local.PRIVATE_SUBNETS]

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.short_az].id

  depends_on = [aws_route_table.private]
}

# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "database" {
  for_each = local.map_route_table_associations[local.DATABASE_SUBNETS]

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.value.short_az].id

  depends_on = [aws_route_table.database]
}


# resource "aws_network_acl_association" "this" {
#   for_each       = toset(local.nacl_keys)
#   network_acl_id = aws_network_acl.this[each.key].id
#   subnet_id      = var.subnets[each.key].id

#   depends_on = [aws_network_acl.this]
# }

