variable "env" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Project namespace"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "default_tags" {
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}


# START: Terraform state location ─────────────────────────────
variable "network_remote_state_config_bucket" {
  type        = string
  description = "S3 Bucket name where the remote network state is stored"
  default     = ""
}

variable "network_remote_state_config_key" {
  type        = string
  description = "S3 Key name where the remote network state is stored"
  default     = ""
}

variable "local_network_source_path" {
  type        = string
  description = "Local path to the network terraform state file"
  default     = ""
}

# START: Routes: NAT Access ─────────────────────────────
variable "nat_access" {
  description = "Controls outbound internet access via NAT Gateways. Keys must be 'private' or 'database'. Set 'all = true' for all AZs or provide specific short AZ names (e.g., ['1A', '1B']) in the 'azs' list."
  type = map(object({
    all = optional(bool, true)
    azs = optional(list(string), [])
  }))
  default = {
    private = {
      all = true
    }
    database = {
      all = true
    }
  }

  validation {
    condition     = length(setsubtract(keys(var.nat_access), ["private", "database"])) == 0
    error_message = "Invalid key found in nat_access. Only 'private' and 'database' are supported."
  }
}

# START: Subnet Association: ISOLATE | QUARANTINE ─────────────────────────────
variable "isolate_subnets" {
  description = "Prevents subnets from being associated with any Route Table, effectively cutting off all routing (Isolation). Keys are tier names ('public', 'private', 'database') and values are lists of subnet keys (e.g., ['1A1', '1B1'])."
  type        = map(list(string))
  default     = {}

  validation {
    # Ensures only valid tier keys are used
    condition     = length(setsubtract(keys(var.isolate_subnets), ["public", "private", "database"])) == 0
    error_message = "Invalid key found in isolate_subnets. Only 'public', 'private', and 'database' are supported."
  }
}

variable "quarantine_subnets" {
  description = "Subnet specified will be attached with QUARANTINE NACL(blackhole). Keys are tier names ('public', 'private', 'database') and values are lists of subnet keys (e.g., ['1A1', '1B1']) to isolate."
  type        = map(list(string))
  default     = {}
  validation {
    condition     = length(setsubtract(keys(var.quarantine_subnets), ["public", "private", "database"])) == 0
    error_message = "Invalid key found in quarantine_subnets. Only 'public', 'private', and 'database' are supported."
  }
}


# START: SHARED NACL Associations: ─────────────────────────────
variable "shared_nacl_associations" {
  description = "Maps specific Shared NACLs to subnet tiers. The top-level key is the target NACL name. The nested map links tier names ('public', 'private', 'database') to lists of subnet keys (e.g., ['1A1'])."
  type        = map(map(list(string)))
  default     = {}

  validation {
    condition     = length(setsubtract(keys(var.shared_nacl_associations), ["public", "private", "database"])) == 0
    error_message = "Invalid key found in shared_nacl_associations. Only 'public', 'private', and 'database' are supported."
  }
}