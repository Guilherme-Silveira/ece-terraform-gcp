variable "zone" {
 type = string
}

variable "hostname" {
 type = string
}

variable "ip" {
 type = string
}


// Configure the Google Cloud provider
provider "google" {
 credentials = file("../credentials.json")
 project     = "inlaid-lane-270316"
 region      = var.zone
}

resource "google_compute_instance" "ansible" {
 name         = var.hostname
 machine_type = "n1-standard-4"
 zone         = "${var.zone}-a"
 hostname     = "${var.hostname}.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = var.ip
   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 metadata = {
   ssh-keys = "silveira:${file("~/.ssh/silveira.pub")}"
 }

 provisioner "file" {
    source      = "/home/silveira/.ssh/silveira"
    destination = "/tmp/silveira"
    connection {
            type = "ssh"
            user = "silveira"
            host = google_compute_instance.ansible.network_interface.0.access_config.0.nat_ip
        }
 }

 provisioner "remote-exec" {
    connection {
            type = "ssh"
            user = "silveira"
            host = google_compute_instance.ansible.network_interface.0.access_config.0.nat_ip
    }
    inline = [
      "sudo yum update -y",
      "sudo yum install -y git ansible",
      "git clone https://github.com/Guilherme-Silveira/ece-ansible.git",
      "cd /home/silveira/ece-ansible",
      "sudo chmod 400 /tmp/silveira",
      "ansible-playbook -i hosts playbooks/ece.yml",
    ]
 }
}

