provider "aws" {
  region = var.aws_region
}

variable "serveo_key_pair" {
  type = string
}

#variable "serveo_domain" {
#  type = string
#}

# TODO: 
# - create security group resource for instance(s) with inbound rules for SSH and HTTPS
# - create EBS resource with only 4GB of storage and associate to instance

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "serveo" {
  key_name_prefix   = "serveo-"
  public_key = var.serveo_key_pair

  tags = {
    Service = "Serveo"
  }
}

resource "aws_instance" "serveo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  monitoring = true  
  key_name = aws_key_pair.serveo.key_name

  tags = {
    Name = "Serveo"
    Service = "Serveo"
  }
}

resource "aws_eip" "serveo" {
  instance = aws_instance.serveo.id
  vpc      = true

  tags = {
    Service = "Serveo"
  }
}

output "serveo_elastic_dns" {
  value = aws_eip.serveo.public_dns
}

output "serveo_instance_dns" {
  value = aws_instance.serveo.public_dns
}
