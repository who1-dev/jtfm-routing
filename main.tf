
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  ROUTE TABLE | PUBLIC PRIVATE, DATABASE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  ROUTE TABLE - Associations | PUBLIC PRIVATE, DATABASE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each = try(local.map_route_table_associations[local.PUBLIC], {})

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each = try(local.map_route_table_associations[local.PRIVATE], {})

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.value.short_az].id

  depends_on = [aws_route_table.private]
}

# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "database" {
  for_each = try(local.map_route_table_associations[local.DATABASE], {})

  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.value.short_az].id

  depends_on = [aws_route_table.database]
}


# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  NACL - Associations | PUBLIC PRIVATE, DATABASE
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_network_acl_association" "public" {
  for_each = try(local.nacls[local.PUBLIC], {})

  network_acl_id = local.nacls[local.PUBLIC][each.key].id
  subnet_id      = local.subnets[local.PUBLIC][each.key].id
}

resource "aws_network_acl_association" "private" {
  for_each = try(local.nacls[local.PRIVATE], {})

  network_acl_id = local.nacls[local.PRIVATE][each.key].id
  subnet_id      = local.subnets[local.PRIVATE][each.key].id
}

resource "aws_network_acl_association" "database" {
  for_each = try(local.nacls[local.DATABASE], {})

  network_acl_id = local.nacls[local.DATABASE][each.key].id
  subnet_id      = local.subnets[local.DATABASE][each.key].id
}


# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#  NACL - Associations | SHARED NACLS
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_network_acl_association" "shared" {
  for_each = local.map_nacl_associations

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
