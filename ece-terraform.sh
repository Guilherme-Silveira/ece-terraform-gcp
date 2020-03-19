cd ./infra-ece-terraform
terraform apply -auto-approve
cd ../ansible-terraform
terraform apply -auto-approve
terraform destroy -auto-approve
