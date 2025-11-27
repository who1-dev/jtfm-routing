data "terraform_remote_state" "local" {
  count = var.local_network_source_path != "" ? 1 : 0
  backend = "local"
  config = {
    path = var.local_network_source_path
  }
}


data "terraform_remote_state" "remote" {
  count = var.network_remote_state_config_bucket != "" && var.network_remote_state_config_key != "" ? 1 : 0
  backend = "s3"
  config = {
    bucket = var.network_remote_state_config_bucket
    key    = var.network_remote_state_config_key
    region = var.region
  }
}
