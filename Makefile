.PHONY: setup provision configure deploy verify reboot destroy

# one-time: ssh key + state bucket
setup:
	./scripts/gen-key.sh
	./scripts/bootstrap-state.sh

# stand up the EC2 instance
provision:
	terraform -chdir=terraform init -input=false
	terraform -chdir=terraform apply -auto-approve

# install docker + start the server
configure:
	cd ansible && ansible-playbook -i inventory.ini playbook.yml

# provision + configure in one go
deploy:
	./scripts/deploy.sh

# scan the running server
verify:
	nmap -sV -Pn -p T:25565 $$(terraform -chdir=terraform output -raw instance_public_ip)

# reboot the instance to show the server auto-starts (then run make verify again)
reboot:
	aws ec2 reboot-instances --region us-east-1 --instance-ids $$(terraform -chdir=terraform output -raw instance_id)

destroy:
	./scripts/destroy.sh
