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
terraform plan
terraform apply
terraform output serveo_elastic_dns >| ../ansible/inventory
popd
```

### Notes
Depending on your shell, the `TF_VAR_serveo_key_pair` might not get set properly.  In that case, copy and paste checking for newline or carriage return characters.
