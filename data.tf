data "terraform_remote_state" "network_resources" {
  backend = "local"
  config = {
    path = "../jtfm-network/terraform.tfstate"
  }
}