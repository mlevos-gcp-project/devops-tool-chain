# Module - terraform-google-network-subnet

Terraform module which creates a google cloud subnetwork with options for [secondary CIDR ranges](https://cloud.google.com/vpc/docs/alias-ip#subnet_primary_and_secondary_cidr_ranges).

## Assumptions

* You want to create a set of subnetworks around an GCP Network.
* You've already created a bunch of subnetworks with distinct configurations (with and without secondary ranges) and want to centralize it in only one module


## Usage
With Secondary CIDR Range

```hcl
module "aliased-subnetwork" {
  source = "./modules/subnetwork"

  name          = "aliased-subnet"
  network       = "${google_compute_network.network.self_link}"
  ip_cidr_range = "10.100.0.0/24"

  create_secondary_ranges = true
  secondary_ranges        = [
    {
      range_name    = "range-1"
      ip_cidr_range = "10.101.0.0/24"
    },
    {
      range_name    = "range-2"
      ip_cidr_range = "10.102.0.0/24"
    },
  ]
}
```
Without Secondary CIDR Range
```hcl
module "basic-subnetwork" {
  source = "./modules/subnetwork"

  name          = "basic-subnet"
  description   = "Basic subnet"
  network       = "${google_compute_network.network.self_link}"
  ip_cidr_range = "10.100.0.0/24"

}
```

Then perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure
  
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Name of subnet. | string | - | yes |
| description | Description usage of subnet | string | `name` subnetwork | no |
| network | Name of selflink to the VPC this subnet will be linked to. Defaults to 'default' network | string | - | yes |
| ip\_cidr\_range | IP range in CIDR format of the subnet | string | - | yes |
| region | Region in which subnet will be created | string | `provider region` | no |
| create\_secondary\_ranges | Enable secondary ip ranges to be used with `secondary_ranges` variable | string | `false` | no |
| secondary\_ranges | Create up to 5 alternative CIDR range to represent this subnetwork | list | `none` | no |

## Outputs

| Name | Description |
|------|-------------|
| name | Subnetwork name |
| gateway\_address | The IP address of the gateway. |
| ip\_cidr\_range | The IP address range that machines in this network are assigned to, represented as a CIDR block |
| secondary\_range\_names | List of names for the secondary ranges created. |
| secondary\_range\_cidrs | List of CIDR blocks for the secondary ranges created. |

### Reference
- [Terraform GCP Subnetwork](https://www.terraform.io/docs/providers/google/d/datasource_compute_subnetwork.html)
- [Terraform Modules](https://www.terraform.io/docs/modules/usage.html)
- [Terraform Interpolation](https://www.terraform.io/docs/configuration/interpolation.html)
- [GCP Alias Subnetworks](https://cloud.google.com/vpc/docs/alias-ip#subnet_primary_and_secondary_cidr_ranges)


## License

MIT Licensed. See [LICENSE](https://github.com/idwall/terraform-google-network-subnet/tree/master/LICENSE) for full details.