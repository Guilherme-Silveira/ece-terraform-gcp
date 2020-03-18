// Configure the Google Cloud provider
provider "google" {
 credentials = file("../../credentials.json")
 project     = "inlaid-lane-270316"
 region      = "us-east4"
}

resource "google_compute_disk" "ece-01" {
 name = "ece-01-data"
 type = "pd-ssd"
 zone = "us-east4-a"
 size = "50"
}

resource "google_compute_disk" "ece-02" {
 name = "ece-02-data"
 type = "pd-ssd"
 zone = "us-east4-b"
 size = "50"
}

resource "google_compute_disk" "ece-03" {
 name = "ece-03-data"
 type = "pd-ssd"
 zone = "us-east4-c"
 size = "50"
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "ece-01" {
 name         = "ece-01"
 machine_type = "n1-standard-8"
 zone         = "us-east4-a"
 hostname     = "ece-01.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = "ece-01-data"
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
 name         = "ece-02"
 machine_type = "n1-standard-8"
 zone         = "us-east4-b"
 hostname     = "ece-02.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = "ece-02-data"
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
 name         = "ece-03"
 machine_type = "n1-standard-8"
 zone         = "us-east4-c"
 hostname     = "ece-03.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
   }
 }

 attached_disk {
   source      = "ece-03-data"
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
  region = "us-east4"
}

resource "google_compute_forwarding_rule" "lb" {
 name                  = "lb-ece"
 region                = "us-east4"
 load_balancing_scheme = "EXTERNAL"
 ip_protocol           = "TCP"
 port_range            = "9243-12443"
 target                = google_compute_target_pool.ece-backend.self_link
}

resource "null_resource" "hosts" {
 triggers = {
   anything1 = google_compute_instance.ece-01.network_interface.0.access_config.0.nat_ip
   anything2 = google_compute_instance.ece-02.network_interface.0.access_config.0.nat_ip
   anything3 = google_compute_instance.ece-03.network_interface.0.access_config.0.nat_ip
   anything4 = google_compute_forwarding_rule.lb.ip_address
 }
 provisioner "remote-exec" {
   connection {
     type = "ssh"
     user = "silveira"
     host = "35.238.3.205"
   }
   inline = [
     "cd /home/silveira/ece-ansible",
     "ansible-playbook -i hosts playbooks/ece.yml",
   ]
 }
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

