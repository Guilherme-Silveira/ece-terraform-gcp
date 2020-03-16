// Configure the Google Cloud provider
provider "google" {
 credentials = file("credentials.json")
 project     = "inlaid-lane-270316"
 region      = "us-central1"
}

resource "google_compute_instance" "ansible" {
 name         = "ansible"
 machine_type = "n1-standard-1"
 zone         = "us-central1-a"
 hostname     = "ansible.srv"

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     size  = "30"
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
      "sudo yum install -y git ansible unzip wget",
      "git clone https://github.com/Guilherme-Silveira/ece-ansible.git",
      "git clone https://github.com/Guilherme-Silveira/ece-terraform-gcp.git",
      "wget https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip -O /home/silveira/terraform.zip",
      "sudo unzip -d /usr/local/bin /home/silveira/terraform.zip",
    ]
 }
}

