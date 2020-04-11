provider "aws" {
  region = var.aws_region
}

variable "jumpbox_key_pair" {
  type = string
}

variable "jumpbox_budget_email" {
  type = string
}

variable "jumpbox_tunnel_source_cidr" {
  type = string
}

variable "jumpbox_budget_start" {
  type = string
}

#variable "jumpbox_domain" {
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

resource "aws_key_pair" "jumpbox" {
  key_name_prefix   = "jumpbox-"
  public_key = var.jumpbox_key_pair

  tags = {
    Service = "Jumpbox"
  }
}

resource "aws_instance" "jumpbox" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  monitoring = true  
  key_name = aws_key_pair.jumpbox.key_name

  security_groups = [ aws_security_group.jumpbox.name ]

  tags = {
    Name = "Jumpbox"
    Service = "Jumpbox"
  }
}

resource "aws_eip" "jumpbox" {
  instance = aws_instance.jumpbox.id
  vpc      = true

  tags = {
    Service = "Jumpbox"
  }
}

resource "aws_security_group" "jumpbox" {
  name = "jumpbox"
  description = "Allow HTTP/HTTPS traffic from anywhere, restrict SSH traffic from home"
  
  ingress {
    description = "SSH from the tunnel source IP address only"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.jumpbox_tunnel_source_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TLS from anywhere"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSHD Tunnel"
    from_port = 2222
    to_port = 2222
    protocol = "tcp"
    cidr_blocks = [var.jumpbox_tunnel_source_cidr]
  }

  egress {
    description = "Anything, anywhere, anytime"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Service = "Jumpbox"
  }
}

resource "aws_budgets_budget" "jumpbox" {
  name              = "Jumpbox"
  budget_type       = "COST"
  limit_amount      = "8.25"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = var.jumpbox_budget_start

  cost_filters = {
    TagKeyValue = "user:Service$Jumpbox" 
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.jumpbox_budget_email]
  }
}


output "jumpbox_elastic_dns" {
  value = aws_eip.jumpbox.public_dns
}

output "jumpbox_instance_dns" {
  value = aws_instance.jumpbox.public_dns
}
