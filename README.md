[![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-gcp-instance/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-gcp-instance/job/master/)
# DC/OS Instances

Creates generic instances for DC/OS nodes

## Usage

```hcl
module "masters" {
  source  = "dcos-terraform/instance/gcp"
  version = "~> 0.2.0"

  providers = {
    google = "google"
  }

  cluster_name             = "${var.cluster_name}"
  hostname_format          = "${var.hostname_format}"
  num                      = "${var.num_masters}"
  image                    = "${coalesce(var.image, module.dcos-tested-oses.gcp_image_name)}"
  user_data                = "${var.image == "" ? module.dcos-tested-oses.os-setup : var.gcp_user_data}"
  machine_type             = "${var.machine_type}"
  instance_subnetwork_name = ["${var.master_subnetwork_name}"]
  ssh_user                 = "${var.ssh_user}"
  public_ssh_key           = "${var.public_ssh_key}"
  zone_list                = "${var.zone_list}"
  disk_type                = "${var.disk_type}"
  disk_size                = "${var.disk_size}"
  tags                     = "${var.tags}"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow_stopping_for_update | If true, allows Terraform to stop the instance to update its properties | string | `true` | no |
| cluster_name | Name of the DC/OS cluster | string | - | yes |
| dcos_instance_os | Operating system to use. Instead of using your own AMI you could use a provided OS. | string | - | yes |
| dcos_version | Specifies which DC/OS version instruction to use. Options: 1.9.0, 1.8.8, etc. See dcos_download_path or dcos_version tree for a full list. | string | - | yes |
| disk_size | Disk Size in GB | string | - | yes |
| disk_type | Disk Type to Leverage The GCE disk type. Can be either 'pd-ssd', 'local-ssd', or 'pd-standard'. (optional) | string | - | yes |
| hostname_format | Format the hostname inputs are index+1, region, cluster_name | string | `%[3]s-instance%[1]d-%[2]s` | no |
| image | Source image to boot from | string | - | yes |
| instance_subnetwork_name | Instance Subnetwork Name | string | - | yes |
| labels | Add custom labels to all resources | map | `<map>` | no |
| machine_type | Instance Type | string | - | yes |
| num_instances | How many instances should be created | string | - | yes |
| public_ssh_key | SSH Public Key | string | - | yes |
| scheduling_preemptible | Deploy instance with preemptible scheduling. (bool) | string | `false` | no |
| ssh_private_key_filename | Path to the SSH private key | string | `/dev/null` | no |
| ssh_user | SSH User | string | - | yes |
| tags | Add custom tags to all resources | list | `<list>` | no |
| user_data | User data to be used on these instances (cloud-init) | string | - | yes |
| zone_list | Element by zone list | list | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| allow_stopping_for_update | If true, allows Terraform to stop the instance to update its properties |
| dcos_instance_os | Operating system to use. Instead of using your own AMI you could use a provided OS. |
| dcos_version | Specifies which DC/OS version instruction to use. Options: 1.9.0, 1.8.8, etc. See dcos_download_path or dcos_version tree for a full list. |
| disk_size | Disk Size in GB |
| disk_type | Disk Type to Leverage The GCE disk type. Can be either 'pd-ssd', 'local-ssd', or 'pd-standard'. (optional) |
| image | Source image to boot from |
| instance_subnetwork_name | Instance Subnetwork Name |
| instances_self_link | List of instance self links |
| machine_type | Instance Type |
| name_prefix | Name Prefix |
| num_instances | How many instances should be created |
| prereq_id | Prereq id used for dependency |
| private_ips | List of private ip addresses created by this module |
| public_ips | List of public ip addresses created by this module |
| public_ssh_key | SSH Public Key |
| scheduling_preemptible | Deploy instance with preemptible scheduling. (bool) |
| ssh_user | SSH User |
| user_data | User data to be used on these instances (cloud-init) |
| zone_list | Element by zone list |

