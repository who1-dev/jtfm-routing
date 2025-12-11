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
  type    = string
  default = "us-east-1"
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

# START: Subnet Isolation ─────────────────────────────
variable "exclude_public_subnet" {
  type        = list(string)
  description = "List of Public Subnet to be excluded in route table association"
  default     = []
}

variable "exclude_private_subnet" {
  type        = list(string)
  description = "List of Private Subnet to be excluded in route table association"
  default     = []
}

variable "exclude_database_subnet" {
  type        = list(string)
  description = "List of Database Subnet to be excluded in route table association"
  default     = []
}

# START: Routes: NAT Access ─────────────────────────────
variable "enable_nat_access_to_all_private_subnets" {
  type        = bool
  description = "This flag will create routes for Private Subnets NAT Access"
  default     = false
}

variable "enable_nat_access_to_all_database_subnets" {
  type        = bool
  description = "This flag will create routes for Database Subnets NAT Access"
  default     = false
}

variable "set_private_subnet_nat_az_connection" {
  type        = list(string)
  description = "A list of Availability Zones to connect Private Subnets to NAT Gateways. Must be a subset of var.azs."
  default     = []
}

variable "set_database_subnet_nat_az_connection" {
  type        = list(string)
  description = "A list of Availability Zones to connect Database Subnets to NAT Gateways. Must be a subset of var.azs."
  default     = []
}