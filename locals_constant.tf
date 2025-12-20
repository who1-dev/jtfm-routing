locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "Environment" : upper(var.env) }

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # WARNING!!! : Changing values below will force recreation of SUBNET at NACL associations
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # NOTE!!! : This keys should exactly match in NETWORK > LOCAL_CONSTANTS. ELSE, code will break
  # Output Keys
  QUARANTINE = "QUARANTINE"
  SUBNETS    = "subnets"
  NACLS      = "nacls"

  #Resource Keys
  SHARED   = "shared"
  PUBLIC   = "public"
  PRIVATE  = "private"
  DATABASE = "database"

  PUBLIC_SHORTENED   = "PUB"
  PRIVATE_SHORTENED  = "PRV"
  DATABASE_SHORTENED = "DB"

  # Dictionary for shortening the Tier Name e.g PUBLIC > PUB
  TIER_LIST = [local.PUBLIC, local.PRIVATE, local.DATABASE]
  TIER_DICTIONARY = {
    (local.PUBLIC) : local.PUBLIC_SHORTENED
    (local.PRIVATE) : local.PRIVATE_SHORTENED
    (local.DATABASE) : local.DATABASE_SHORTENED
  }

}