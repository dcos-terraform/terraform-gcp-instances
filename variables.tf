variable "num_instances" {
  description = "How many instances should be created"
}

variable "cluster_name" {
  description = "Name of the DC/OS cluster"
}

variable "machine_type" {
  description = "Instance Type"
}

variable "dcos_instance_os" {
  description = "Operating system to use. Instead of using your own AMI you could use a provided OS."
}

variable "ssh_private_key_filename" {
  description = "Path to the SSH private key"

  # cannot leave this empty as the file() interpolation will fail later on for the private_key local variable
  # https://github.com/hashicorp/terraform/issues/15605
  default = "/dev/null"
}

variable "zone_list" {
  description = "Element by zone list"
  type        = list(string)
}

variable "image" {
  description = "Source image to boot from"
}

variable "disk_type" {
  description = "Disk Type to Leverage The GCE disk type. Can be either 'pd-ssd', 'local-ssd', or 'pd-standard'. (optional)"
}

variable "disk_size" {
  description = "Disk Size in GB"
}

variable "instance_subnetwork_name" {
  description = "Instance Subnetwork Name"
}

variable "user_data" {
  description = "User data to be used on these instances (cloud-init)"
}

variable "ssh_user" {
  description = "SSH User"
}

# SSH Public Key
variable "public_ssh_key" {
  description = "SSH Public Key"
}

variable "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance to update its properties"
  default     = "true"
}

variable "tags" {
  type        = list(string)
  description = "Add custom tags to all resources"
  default     = []
}

variable "labels" {
  description = "Add custom labels to all resources"
  type        = map(string)
  default     = {}
}

variable "hostname_format" {
  description = "Format the hostname inputs are index+1, region, cluster_name"
  default     = "%[3]s-instance%[1]d-%[2]s"
}

variable "scheduling_preemptible" {
  description = "Deploy instance with preemptible scheduling. (bool)"
  default     = false
}

variable "guest_accelerator_type" {
  description = "Type of guest accelerator"
  default     = "nvidia-tesla-k80"
}

variable "guest_accelerator_count" {
  description = "Count of guest accelerator type"
  default     = 0
}

variable "name_prefix" {
  description = "Name Prefix"
  default     = ""
}

