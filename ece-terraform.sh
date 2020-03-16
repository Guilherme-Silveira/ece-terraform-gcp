cd ./infra-ece-terraform
echo yes | terraform apply
cd ../ansible-terraform
echo yes | terraform apply
echo yes | terraform destroy
