terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
  backend "gcs" {
    bucket = "qadevoprac3-lab10-tfstate-8753-27545"
    prefix = "terraform/state/lab10"
  }
}

variable "gcp_project" {}
variable "docker_registry" {}

provider "google" {
  project = var.gcp_project
  region  = "europe-west1"
}

resource "google_compute_instance" "docker_server" {
  name = "app-server"
  machine_type = "e2-medium"
  zone = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-2404-lts-amd64"
      size  = 16
    }
  }

  metadata_startup_script = <<EOF
  apt-get update
  apt-get install -y docker.io
  systemctl enable --now docker
  docker run -d -p 80:80 ${var.docker_registry}:latest
  EOF

  network_interface {
    network = "default"
    access_config {}
  }
}

resource "google_compute_firewall" "default" {
  name    = "server-firewall"
  network = "default"
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    ports = ["22", "80"]
    protocol = "icmp"
  }

  allow {
    ports = ["22", "80"]
    protocol = "tcp"
  }
}