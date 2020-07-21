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
     user = var.bastion_user
     host = var.bastion_ip
     private_key = file(var.bastion_private_key)
   }
   inline = [
     "cd ${var.ansible_home}",
     "cat << EOF > hosts",
     "[primary]",
     "${var.ip1}",
     "[primary:vars]",
     "availability_zone=${var.az1}",
     "[secondary]",
     "${var.ip2}",
     "[secondary:vars]",
     "availability_zone=${var.az2}",
     "[tertiary]",
     "${var.ip3}",
     "[tertiary:vars]"
     "availability_zone=${var.az3}",
     "[gcp:children]",
     "primary",
     "secondary",
     "tertiary",
     "[gcp:vars]",
     "ansible_ssh_private_key_file=${var.ansible_private_key}",
     "ansible_user=${var.user}",
     "ansible_become=yes",
     "device_name=${var.device_name}"
     "EOF",
     "ansible-playbook -i hosts ece.yml",
   ]
 }
}
