variable "gce_ssh_user" {
  default = "root"
}
variable "gce_ssh_pub_key_file" {
  default = "~/.ssh/google_compute_engine.pub"
}

variable "gce_zone" {
  type = "string"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("adc.json")}"
}

resource "google_compute_network" "default" {
  name                    = "my-kubernetes-projet"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "default" {
  name            = "kubernetes"
  network         = "${google_compute_network.default.name}"
  ip_cidr_range   = "10.240.0.0/24"
}

resource "google_compute_firewall" "internal" {
  name    = "my-kubernetes-projet-allow-internal"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "http"
  }

  allow {
    protocol = "https"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = [ "10.240.0.0/24","10.200.0.0/16" ]
}

resource "google_compute_firewall" "external" {
  name    = "my-kubernetes-projet-allow-external"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "http"
  }

  allow {
    protocol = "https"
  }


  allow {
    protocol = "udp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_address" "default" {
  name = "my-kubernetes-projet"
}

resource "google_compute_instance" "master" {
  count = 3
  name            = "master-${count.index}"
  machine_type    = "n1-standard-1"
  zone            = "${var.gce_zone}"
  can_ip_forward  = true

  tags = ["my-kubernetes-projet","master"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.default.name}"
    network_ip = "10.240.0.1${count.index}"

    access_config {
      // Ephemeral IP
    }
  }
  
  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  metadata = {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  metadata_startup_script = "apt-get install -y python"
}

resource "google_compute_instance" "worker" {
  count = 3
  name            = "worker-${count.index}"
  machine_type    = "n1-standard-1"
  zone            = "${var.gce_zone}"
  can_ip_forward  = true

  tags = ["my-kubernetes-projet","worker"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.default.name}"
    network_ip = "10.240.0.2${count.index}"

    access_config {
      // Ephemeral IP
    }
  }
  
  service_account {
    scopes = ["compute-rw","storage-ro","service-management","service-control","logging-write","monitoring"]
  }

  metadata = {
    pod-cidr = "10.200.${count.index}.0/24"
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  metadata_startup_script = "apt-get install -y python"
}
