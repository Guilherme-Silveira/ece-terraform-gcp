resource "google_compute_disk" "ece-01" {
 name = var.disk1
 type = var.disk_type
 zone = var.zone1
 size = var.disk_size
}

resource "google_compute_disk" "ece-02" {
 name = var.disk2
 type = var.disk_type
 zone = var.zone2
 size = var.disk_size
}

resource "google_compute_disk" "ece-03" {
 name = var.disk3
 type = var.disk_type
 zone = var.zone3
 size = var.disk_size
}

resource "google_compute_instance" "ece-01" {
 name         = var.instance1
 machine_type = var.machine_type
 zone         = var.zone1
 hostname     = var.hostname1

 boot_disk {
   initialize_params {
     image = var.image
     size  = var.so_disk_size
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-01.name
   device_name = var.device_name
 }

 network_interface {
   network    = var.network
   network_ip = var.ip1
   access_config {}
 }
 metadata = {
   ssh-keys = "${var.user}:${file(var.ssh_key)}"
 }
}

resource "google_compute_instance" "ece-02" {
 name         = var.instance2
 machine_type = var.machine_type
 zone         = var.zone2
 hostname     = var.hostname2

 boot_disk {
   initialize_params {
     image = var.image
     size  = var.so_disk_size
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-02.name
   device_name = var.device_name
 }

 network_interface {
   network    = var.network
   network_ip = var.ip2
   access_config {}
 }
 metadata = {
   ssh-keys = "${var.user}:${file(var.ssh_key)}"
 }
}

resource "google_compute_instance" "ece-03" {
 name         = var.instance3
 machine_type = var.machine_type
 zone         = var.zone3
 hostname     = var.hostname3

 boot_disk {
   initialize_params {
     image = var.image
     size  = var.so_disk_size
   }
 }

 attached_disk {
   source      = google_compute_disk.ece-03.name
   device_name = var.device_name
 }

 network_interface {
   network    = var.network
   network_ip = var.ip3
   access_config {}
 }
 metadata = {
   ssh-keys = "${var.user}:${file(var.ssh_key)}"
 }
}

resource "google_compute_target_pool" "ece-backend" {
  name = var.target_pool_name

  instances = [
    google_compute_instance.ece-01.self_link,
    google_compute_instance.ece-02.self_link,
    google_compute_instance.ece-03.self_link,
  ]
  region = var.region
}

resource "google_compute_forwarding_rule" "lb" {
 name                  = var.lb_name
 region                = var.region
 load_balancing_scheme = "EXTERNAL"
 ip_protocol           = "TCP"
 port_range            = "9243-12443"
 target                = google_compute_target_pool.ece-backend.self_link
}
