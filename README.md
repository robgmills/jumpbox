# Serveo In AWS

Launch an instance of [Serveo](https://serveo.net) in AWS instantly. 

(Just add creds!)

## Dependencies

* Terraform v0.12.24
* Ansible 2.9.6

## Quick Start

Setup your [AWS credentials and configuration according to the AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) and [generate a public and private SSH key](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to use to connect to the EC2 instance.

```sh
pushd terraform
terraform init
export TF_VAR_serveo_key_pair="$(ssh-keygen -y -f ~/.ssh/id_rsa)"
export TF_VAR_serveo_budget_email="YOUR_EMAIL@YOUR_PROVIDER.COM"
export TF_VAR_serveo_budget_start=$(date +"%Y-%m-%d_%H:%M")
terraform plan
terraform apply
terraform output serveo_elastic_dns >| ../ansible/inventory
popd

pushd
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventory -u ubuntu serveo.yml
popd
```

### Notes
Depending on your shell, the `TF_VAR_serveo_key_pair` might not get set properly.  In that case, copy and paste checking for newline or carriage return characters.
