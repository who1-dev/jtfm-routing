locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "Environment" : upper(var.env) }

  # Constant Naming conventions:
  VPC      = "VPC"
  IGW      = "IGW"
  NATGW    = "NATGW"
  EIP      = "EIP"
  PRV_SUB  = "PRVSUB"
  PUB_SUB  = "PUBSUB"
  DB_SUB   = "DBSUB"
  PRV_RT   = "PRVRT"
  PUB_RT   = "PUBRT"
  DB_RT    = "DBRT"
  RT_ASSOC = "RTASSOC"

}