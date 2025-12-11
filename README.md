# JTFM-Routing
A Terraform module to provision AWS routing infrastructure. It handles the creation of Route Tables and Associations for Public, Private, and Database subnets, with flexible configuration options for NAT Gateway access and subnet isolation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.23.0 |

## Modules

No modules.

# Features
* **State Integration** : Retrieval of VPC network context via S3 remote state or local state files.

* **Layered Routing** : Automated setup for Public, Private, and Database Route Tables.
Layered Routing: Automated setup for Public, Private, and Database Route Tables.

* **Connectivity Controls** : Toggles for Internet Gateway and NAT Gateway access per layer.

* **Granular Isolation** : Ability to exclude specific subnets or restrict NAT access to specific Availability Zones.


## Data Sources
| Name | Type | Description |
|------|------|------|
| [terraform_remote_state.local](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source | Local terraform state location referencing
| [terraform_remote_state.remote](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source | Remote backend s3 state location


## Resources

> ### Route Tables
| Name | Type |
|------|------|
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
> ### Route Table Associations
| Name | Type |
|------|------|
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |

> ### Internet Access
| Name | Type |
|------|------|
| [aws_route.public_internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.database_nat_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |






## Inputs

> ### Terraform States
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_local_network_source_path"></a> [local\_network\_source\_path](#input\_local\_network\_source\_path) | Local path to the network terraform state file | `string` | `""` | no |
| <a name="input_network_remote_state_config_bucket"></a> [network\_remote\_state\_config\_bucket](#input\_network\_remote\_state\_config\_bucket) | S3 Bucket name where the remote network state is stored | `string` | `""` | no |
| <a name="input_network_remote_state_config_key"></a> [network\_remote\_state\_config\_key](#input\_network\_remote\_state\_config\_key) | S3 Key name where the remote network state is stored | `string` | `""` | no |

> ### Core
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Deployment environment (e.g., dev, prod) | `string` | `"dev"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` |  `jc` | yes |


> ### Subnet Isolation
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_exclude_public_subnet"></a> [exclude\_public\_subnet](#input\_exclude\_public\_subnet) | List of Public Subnet to be excluded in route table association | `list(string)` | `[]` | no |
| <a name="input_exclude_private_subnet"></a> [exclude\_private\_subnet](#input\_exclude\_private\_subnet) | List of Private Subnet to be excluded in route table association | `list(string)` | `[]` | no |
| <a name="input_exclude_database_subnet"></a> [exclude\_database\_subnet](#input\_exclude\_database\_subnet) | List of Database Subnet to be excluded in route table association | `list(string)` | `[]` | no |

> ### Routes: NAT Access
>>### Note: NAT Gateways require a Public Subnet in the same Availability Zone.
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_nat_access_to_all_private_subnets"></a> [enable\_nat\_access\_to\_all\_private\_subnets](#input\_enable\_nat\_access\_to\_all\_private\_subnets) | This flag will create routes for Private Subnets NAT Access | `bool` | `false` | no |
| <a name="input_enable_nat_access_to_all_database_subnets"></a> [enable\_nat\_access\_to\_all\_database\_subnets](#input\_enable\_nat\_access\_to\_all\_database\_subnets) | This flag will create routes for Database Subnets NAT Access | `bool` | `false` | no |
| <a name="input_set_private_subnet_nat_az_connection"></a> [set\_private\_subnet\_nat\_az\_connection](#input\_set\_private\_subnet\_nat\_az\_connection) | A list of Availability Zones to connect Private Subnets to NAT Gateways. Must be a subset of var.azs. | `list(string)` | `[]` | no |
| <a name="input_set_database_subnet_nat_az_connection"></a> [set\_database\_subnet\_nat\_az\_connection](#input\_set\_database\_subnet\_nat\_az\_connection) | A list of Availability Zones to connect Database Subnets to NAT Gateways. Must be a subset of var.azs. | `list(string)` | `[]` | no |






## Outputs

No outputs.
<!-- END_TF_DOCS -->