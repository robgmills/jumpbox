.PHONY: all init setupAWS provisionAWS deploy removeSSHHost createInventory connect help

KEY=`cat ~/.ssh/id_rsa.pub`
EMAIL=""
START=`date +"%Y-%m-%d_%H:%M"`
CIDR=`curl -s ipinfo.io/ip`
KEY_NAME=`terraform output -state=../setup/terraform.tfstate jumpbox_key_pair`
HOST=`terraform output -state=terraform/terraform.tfstate jumpbox_elastic_dns`
CERTBOT_DOMAIN ?= ${HOST}
CERTBOT_EMAIL ?= ${EMAIL}
SSHD_AUTHORIZED_KEY ?=${KEY}
LOCAL_PORT ?= 80

all: init setupAWS provisionAWS removeSSHHost createInventory deploy connect

init:
	@pushd terraform > /dev/null; \
	terraform init; \
	popd > /dev/null; \
	pushd setup > /dev/null; \
	terraform init; \
	popd > /dev/null

setupAWS:
	@pushd setup > /dev/null; \
	terraform apply -var="jumpbox_key_pair=${KEY}" -var="jumpbox_budget_email=${EMAIL}" -var="jumpbox_budget_start=${START}"

provisionAWS:
	@pushd terraform > /dev/null; \
	terraform apply -var="jumpbox_key_name=${KEY_NAME}" -var="jumpbox_tunnel_source_cidr=${CIDR}/32"

removeSSHHost:
	@ssh-keygen -R "${HOST}"; \
	ssh-keygen -R "[${HOST}]:2222" 

createInventory:
	@echo ${HOST} >| ansible/inventory &&\
	echo Generated ansible inventory

deploy:
	@ansible-playbook -C -i ansible/inventory -u ubuntu ansible/jumpbox.yml

connect:
	ssh -vnNT -R 8080:localhost:{LOCAL_PORT} -p 2222 ${USER}@${HOST}

help:
	@cat README.md
