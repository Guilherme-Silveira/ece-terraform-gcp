variable "disk1" {
 type = string
}

variable "disk2" {
 type = string
}

variable "disk3" {
 type = string
}

variable "instance1" {
 type = string
}

variable "instance2" {
 type = string
}

variable "instance3" {
 type = string
}

variable "zone" {
 type = string
}

variable "disk_size" {
 type = string
}

provider "google" {
 credentials = file("../credentials.json")
 project     = "inlaid-lane-270316"
 region      = var.zone
}

resource "google_compute_disk" "ece-01" {
 name = var.disk1
 type = "pd-ssd"
 zone = "${var.zone}-a"
 size = var.disk_size
}

resource "google_compute_disk" "ece-02" {
 name = var.disk2
 type = "pd-ssd"
 zone = "${var.zone}-b"
 size = var.disk_size
}

resource "google_compute_disk" "ece-03" {
 name = var.disk3
 type = "pd-ssd"
 zone = "${var.zone}-c"
 size = var.disk_size
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "ece-01" {
 name         = var.instance1
 machine_type = "n1-standard-8"
 zone         = "${var.zone}-a"
 hostname     = "${var.instance1}.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-01.name
   device_name = "sdb"
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.10"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }
 metadata = {
   ssh-keys = "silveira:${file("~/.ssh/silveira.pub")}"
 }
}

resource "google_compute_instance" "ece-02" {
 name         = var.instance2
 machine_type = "n1-standard-8"
 zone         = "${var.zone}-b"
 hostname     = "${var.instance2}.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-02.name
   device_name = "sdb"
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.11"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }
 metadata = {
   ssh-keys = "silveira:${file("~/.ssh/silveira.pub")}"
 }
}

resource "google_compute_instance" "ece-03" {
 name         = var.instance3
 machine_type = "n1-standard-8"
 zone         = "${var.zone}-c"
 hostname     = "${var.instance3}.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-03.name
   device_name = "sdb"
 }

 network_interface {
   network    = "default"
   network_ip = "10.150.0.12"
   access_config {
     // Include this section to give the VM an external ip address
   }
 }
 metadata = {
   ssh-keys = "silveira:${file("~/.ssh/silveira.pub")}"
 }
}

resource "google_compute_target_pool" "ece-backend" {
  name = "ece-backend"

  instances = [
    google_compute_instance.ece-01.self_link,
    google_compute_instance.ece-02.self_link,
    google_compute_instance.ece-03.self_link,
  ]
  region = var.zone
}

resource "google_compute_forwarding_rule" "lb" {
 name                  = "lb-ece"
 region                = var.zone
 load_balancing_scheme = "EXTERNAL"
 ip_protocol           = "TCP"
 port_range            = "9243-12443"
 target                = google_compute_target_pool.ece-backend.self_link
}

//-------------------------------------------------------------------------------------------------------------------------

/*
resource "google_compute_instance_group" "ece-01" {
 name      = "ece-01"
 zone      = "us-east4-a"
 instances = [
   google_compute_instance.ece-01.self_link
 ]
}

resource "google_compute_instance_group" "ece-02" {
 name      = "ece-02"
 zone      = "us-east4-b"
 instances = [
   google_compute_instance.ece-02.self_link
 ]
}

resource "google_compute_instance_group" "ece-03" {
 name      = "ece-03"
 zone      = "us-east4-c"
 instances = [
   google_compute_instance.ece-03.self_link
 ]
}
*/

