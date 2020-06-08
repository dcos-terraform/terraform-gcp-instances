output "num_instances" {
  description = "How many instances should be created"
  value       = var.num_instances
}

output "name_prefix" {
  description = "Name Prefix"
  value       = var.cluster_name
}

output "machine_type" {
  description = "Instance Type"
  value       = var.machine_type
}

output "dcos_instance_os" {
  description = "Operating system to use. Instead of using your own AMI you could use a provided OS."
  value       = var.dcos_instance_os
}

output "zone_list" {
  description = "Element by zone list"
  value       = var.zone_list
}

output "image" {
  description = "Source image to boot from"
  value       = var.image
}

output "disk_type" {
  description = "Disk Type to Leverage The GCE disk type. Can be either 'pd-ssd', 'local-ssd', or 'pd-standard'. (optional)"
  value       = var.disk_type
}

output "disk_size" {
  description = "Disk Size in GB"
  value       = var.disk_size
}

output "instance_subnetwork_name" {
  description = "Instance Subnetwork Name"
  value       = var.instance_subnetwork_name
}

output "user_data" {
  description = "User data to be used on these instances (cloud-init)"
  value       = var.user_data
}

output "ssh_user" {
  description = "SSH User"
  value       = coalesce(var.ssh_user, module.dcos-tested-oses.user)
}

output "public_ssh_key" {
  description = "SSH Public Key"
  value       = var.public_ssh_key
}

output "allow_stopping_for_update" {
  description = "If true, allows Terraform to stop the instance to update its properties"
  value       = var.allow_stopping_for_update
}

output "private_ips" {
  description = "List of private ip addresses created by this module"
  value       = google_compute_instance.instances.*.network_interface.0.network_ip
}

output "public_ips" {
  description = "List of public ip addresses created by this module"
  value       = google_compute_instance.instances.*.network_interface.0.access_config.0.nat_ip
}

output "instances_self_link" {
  description = "List of instance self links"
  value       = google_compute_instance.instances.*.self_link
}

output "scheduling_preemptible" {
  description = "Deploy instance with preemptible scheduling. (bool)"
  value       = var.scheduling_preemptible
}

output "prereq_id" {
  description = "Prereq id used for dependency"
  value       = ""
}
