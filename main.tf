/**
 * [![Build Status](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-gcp-instance/job/master/badge/icon)](https://jenkins-terraform.mesosphere.com/service/dcos-terraform-jenkins/job/dcos-terraform/job/terraform-gcp-instance/job/master/)
 * # DC/OS Instances
 *
 * Creates generic instances for DC/OS nodes
 *
 * ## Usage
 *
 *```hcl
 * module "masters" {
 *   source  = "dcos-terraform/instance/gcp"
 *   version = "~> 0.2.0"
 *
 *   providers = {
 *     google = "google"
 *   }
 *
 *   cluster_name             = "${var.cluster_name}"
 *   hostname_format          = "${var.hostname_format}"
 *   num                      = "${var.num_masters}"
 *   image                    = "${coalesce(var.image, module.dcos-tested-oses.gcp_image_name)}"
 *   user_data                = "${var.image == "" ? module.dcos-tested-oses.os-setup : var.gcp_user_data}"
 *   machine_type             = "${var.machine_type}"
 *   instance_subnetwork_name = ["${var.master_subnetwork_name}"]
 *   ssh_user                 = "${var.ssh_user}"
 *   public_ssh_key           = "${var.public_ssh_key}"
 *   zone_list                = "${var.zone_list}"
 *   disk_type                = "${var.disk_type}"
 *   disk_size                = "${var.disk_size}"
 *   tags                     = "${var.tags}"
 * }
 *```
 */

provider "google" {}

data "google_client_config" "current" {}

// If name_prefix exists, merge it into the cluster_name
locals {
  cluster_name        = var.name_prefix != "" ? "${var.name_prefix}-${var.cluster_name}" : var.cluster_name
  private_key         = file(var.ssh_private_key_filename)
  agent               = var.ssh_private_key_filename == "/dev/null" ? true : false
  on_host_maintenance = var.guest_accelerator_count > 0 ? "TERMINATE" : "MIGRATE"
}

module "dcos-tested-oses" {
  source  = "dcos-terraform/tested-oses/gcp"
  version = "~> 0.3.0"

  providers = {
    google = google
  }

  os = var.dcos_instance_os
}

resource "google_compute_instance" "instances" {
  count = var.num_instances
  name = format(
    var.hostname_format,
    count.index + 1,
    data.google_client_config.current.region,
    local.cluster_name,
  )
  machine_type              = var.machine_type
  can_ip_forward            = false
  zone                      = element(var.zone_list, count.index)
  allow_stopping_for_update = var.allow_stopping_for_update

  boot_disk {
    initialize_params {
      image = coalesce(var.image, module.dcos-tested-oses.image_name)
      type  = var.disk_type
      size  = var.disk_size
    }

    auto_delete = true
  }

  network_interface {
    subnetwork = var.instance_subnetwork_name

    access_config {
      // Ephemeral IP
    }
  }

  tags = concat(
    var.tags,
    [
      format(
        var.hostname_format,
        count.index + 1,
        data.google_client_config.current.region,
        local.cluster_name,
      ),
      local.cluster_name,
    ],
  )

  labels = merge(
    var.labels,
    {
      "name" = format(
        var.hostname_format,
        count.index + 1,
        data.google_client_config.current.region,
        local.cluster_name,
      )
      "cluster"           = local.cluster_name
      "kubernetescluster" = local.cluster_name
    },
  )

  metadata = {
    user-data = var.user_data
    sshKeys   = "${coalesce(var.ssh_user, module.dcos-tested-oses.user)}:${file(var.public_ssh_key)}"
  }

  lifecycle {
    ignore_changes = [
      labels.name,
      labels.cluster,
    ]
  }

  scheduling {
    preemptible = var.scheduling_preemptible

    # it always needs to be "TERMINATE as soon as preemptible is set to true."
    on_host_maintenance = var.scheduling_preemptible ? "TERMINATE" : local.on_host_maintenance
    automatic_restart   = "false"
  }

  guest_accelerator {
    type  = var.guest_accelerator_type
    count = var.guest_accelerator_count
  }
}
