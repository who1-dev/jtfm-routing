output "route_tables" {
  description = "Map containing the ID, ARN, and Owner ID for each created Route Table."
  value = {
    for k, v in aws_route_table.this : k => {
      id       = v.id
      arn      = v.arn
      owner_id = v.owner_id
    }
  }
}