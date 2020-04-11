# Serveo-like Jumpbox

Bust NAT'd networks and network filewalls to reach a local host.  Launch a "jumpbox" with [Serveo](https://jumpbox.net)-like SSH tunneling and HTTPS forwarding in AWS, instantly. 

(Just add creds!)

## Dependencies

* Terraform v0.12.24
* Ansible 2.9.6

## Quick Start

Setup your [AWS credentials and configuration according to the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) and [generate a public and private SSH key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to use to connect to the EC2 instance.

```sh
pushd setup
export TF_VAR_jumpbox_key_pair=$(ssh-keygen -y -f ~/.ssh/id_rsa)
export TF_VAR_jumpbox_budget_email="YOUR_EMAIL@YOUR_PROVIDER.COM"
export TF_VAR_jumpbox_budget_start=$(date +"%Y-%m-%d_%H:%M")
terraform plan
terraform apply
export TF_VAR_jumpbox_key_name=$(terraform output jumpbox_key_pair) // used in next module
popd

pushd terraform
terraform init
export TF_VAR_jumpbox_tunnel_source_cidr="$(curl -s ipinfo.io/ip)/32"
terraform plan
terraform apply
terraform output jumpbox_elastic_dns >| ../ansible/inventory
popd

pushd ansible
export CERTBOT_DOMAIN=yourdomain.com
export CERTBOT_EMAIL=YOUR_EMAIL@YOUR_PROVIDER.COM
export SSHD_AUTHORIZED_KEY=$(ssh-keygen -y -f ~/.ssh/id_rsa)
ansible-playbook -i inventory -u ubuntu jumpbox.yml
popd
```
