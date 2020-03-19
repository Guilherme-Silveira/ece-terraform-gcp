cd ./infra-ece-terraform
terraform apply -var-file="ece.tfvars" -auto-approve
cd ../ansible-terraform
terraform apply -var-file="ansible.tfvars" -auto-approve
terraform destroy -var-file="ansible.tfvars" -auto-approve
