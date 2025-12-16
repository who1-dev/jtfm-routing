locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "Environment" : upper(var.env) }

  # Constant Naming conventions:
  PRV_RT   = "PRVRT"
  PUB_RT   = "PUBRT"
  DB_RT    = "DBRT"
  RT_ASSOC = "RTASSOC"

  #Output Keys
  PUBLIC_SUBNETS   = "public_subnets"
  PRIVATE_SUBNETS  = "private_subnets"
  DATABASE_SUBNETS = "database_subnets"

  #Resource Keys
  SHARED   = "shared"
  PUBLIC   = "public"
  PRIVATE  = "private"
  DATABASE = "database"

}