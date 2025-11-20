terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("${path.module}/gcp-key.json")
  project     = var.project
  region      = var.region
}

# --- VPC ---
resource "google_compute_network" "spark_vpc" {
  name                    = "spark-vpc"
  auto_create_subnetworks = false
}

# --- Subnet ---
resource "google_compute_subnetwork" "spark_subnet" {
  name          = "spark-subnet"
  region        = var.region
  network       = google_compute_network.spark_vpc.id
  ip_cidr_range = "10.0.0.0/16"
}

# --- Firewall ---
resource "google_compute_firewall" "spark_firewall" {
  name    = "spark-firewall"
  network = google_compute_network.spark_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "7077", "8080", "4040"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# --- Master Node ---
resource "google_compute_instance" "spark_master" {
  name         = "spark-master"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.spark_vpc.id
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  tags = ["spark-master"]
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

}

# --- Worker Nodes ---
resource "google_compute_instance" "spark_workers" {
  count        = var.worker_count
  name         = "spark-worker-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.spark_vpc.id
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  tags = ["spark-worker"]

 metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "master_ip" {
  value = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
}

output "worker_ips" {
  value = [for w in google_compute_instance.spark_workers : w.network_interface[0].access_config[0].nat_ip]
 

}
