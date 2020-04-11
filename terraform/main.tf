provider "aws" {
  region = var.aws_region
}

variable "jumpbox_tunnel_source_cidr" {
  type = string
}

variable "jumpbox_key_name" {
  type = string
}

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

resource "aws_instance" "jumpbox" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"
  monitoring = true  
  key_name = "jumpbox-20200405021823048000000001"

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

output "jumpbox_elastic_dns" {
  value = aws_eip.jumpbox.public_dns
}

output "jumpbox_instance_dns" {
  value = aws_instance.jumpbox.public_dns
}
