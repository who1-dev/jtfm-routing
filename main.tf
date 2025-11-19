# # Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_RT)
  })
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  for_each = toset(local.list_private_az_keys)

  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PRV_RT, each.key)
  })

}

# Create a Database Route Table
resource "aws_route_table" "database" {
  for_each = toset(local.list_database_az_keys)

  vpc_id = local.network.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_RT, each.key)
  })
}


# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each       = local.network.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each = local.network.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.short_az].id

  depends_on = [aws_route_table.private]
}

# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "database" {
  for_each = local.network.database_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.value.short_az].id

  depends_on = [aws_route_table.database]
}