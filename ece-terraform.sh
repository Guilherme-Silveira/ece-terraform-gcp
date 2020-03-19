cd ./infra-ece-terraform
terraform apply -var-file="ece.tfvars" -auto-approve
cd ../ansible-terraform
terraform apply -var-file="ece.tfvars" -auto-approve
terraform destroy -var-file="ece.tfvars" -auto-approve
