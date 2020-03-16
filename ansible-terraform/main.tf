// Configure the Google Cloud provider
provider "google" {
 credentials = file("../credentials.json")
 project     = "inlaid-lane-270316"
 region      = "us-central1"
}

resource "google_compute_instance" "ansible" {
 name         = "ansible"
 machine_type = "n1-standard-4"
 zone         = "us-central1-a"
 hostname     = "ansible.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "50"
   }
 }

 network_interface {
   network    = "default"
   network_ip = "10.128.0.10"
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

