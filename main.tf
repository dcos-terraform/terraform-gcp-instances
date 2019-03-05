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

provider "google" {
  version = "~> 2.0"
}

data "google_client_config" "current" {}

locals {
  private_key = "${file(var.ssh_private_key_filename)}"
  agent       = "${var.ssh_private_key_filename == "/dev/null" ? true : false}"
}

module "dcos-tested-oses" {
  source  = "dcos-terraform/tested-oses/gcp"
  version = "~> 0.1.0"

  providers = {
    google = "google"
  }

  os           = "${var.dcos_instance_os}"
  dcos_version = "${var.dcos_version}"
}

resource "google_compute_instance" "instances" {
  count                     = "${var.num_instances}"
  name                      = "${format(var.hostname_format, count.index + 1, data.google_client_config.current.region, var.cluster_name)}"
  machine_type              = "${var.machine_type}"
  can_ip_forward            = false
  zone                      = "${element(var.zone_list, count.index)}"
  allow_stopping_for_update = "${var.allow_stopping_for_update}"

  boot_disk {
    initialize_params {
      image = "${coalesce(var.image, module.dcos-tested-oses.image_name)}"
      type  = "${var.disk_type}"
      size  = "${var.disk_size}"
    }

    auto_delete = true
  }

  network_interface {
    subnetwork = "${var.instance_subnetwork_name}"

    access_config = {
      // Ephemeral IP
    }
  }

  tags = ["${concat(var.tags,list(format(var.hostname_format, count.index + 1, data.google_client_config.current.region, var.cluster_name), var.cluster_name))}"]

  labels = "${merge(var.labels, map("name", format(var.hostname_format, (count.index + 1), data.google_client_config.current.region, var.cluster_name),
                                    "cluster", var.cluster_name,
                                    "kubernetescluster", var.cluster_name))}"

  metadata = {
    user-data = "${var.user_data}"
    sshKeys   = "${coalesce(var.ssh_user, module.dcos-tested-oses.user)}:${file(var.public_ssh_key)}"
  }

  lifecycle {
    ignore_changes = ["labels.name", "labels.cluster"]
  }

  scheduling {
    preemptible       = "${var.scheduling_preemptible}"
    automatic_restart = "false"
  }
}

resource "null_resource" "instance-prereq" {
  # If the user supplies an AMI or user_data we expect the prerequisites are met.
  count = "${var.image == "" ? var.num_instances : 0}"

  connection {
    host        = "${element(google_compute_instance.instances.*.network_interface.0.access_config.0.nat_ip, count.index)}"
    user        = "${coalesce(var.ssh_user, module.dcos-tested-oses.user)}"
    private_key = "${local.private_key}"
    agent       = "${local.agent}"
  }

  provisioner "file" {
    content     = "${module.dcos-tested-oses.os-setup}"
    destination = "/tmp/dcos-prereqs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dcos-prereqs.sh",
      "sudo bash -x /tmp/dcos-prereqs.sh",
    ]
  }

  depends_on = ["google_compute_instance.instances"]
}
