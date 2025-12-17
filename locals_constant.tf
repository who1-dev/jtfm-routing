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

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # WARNING!!! : Changing values below will force recreation of SUBNET at NACL associations
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  PUBLIC_SHORTENED   = "PUB"
  PRIVATE_SHORTENED  = "PRV"
  DATABASE_SHORTENED = "DB"

  # NOTE!!! : This keys should excatly match in NETWORK > LOCAL_CONSTANTS. ELSE, code will break
  # Output Keys
  QUARANTINE = "QUARANTINE"
  SUBNETS    = "subnets"
  NACLS      = "nacls"

  #Resource Keys
  SHARED   = "shared"
  PUBLIC   = "public"
  PRIVATE  = "private"
  DATABASE = "database"

  # Dictionary for shortening the Tier Name e.g PUBLIC > PUB
  TIER_DICTIONARY = {
    (local.PUBLIC) : local.PUBLIC_SHORTENED
    (local.PRIVATE) : local.PRIVATE_SHORTENED
    (local.DATABASE) : local.DATABASE_SHORTENED
  }

}