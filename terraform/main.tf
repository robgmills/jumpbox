provider "aws" {
  region = var.aws_region
}

variable "serveo_key_pair" {
  type = string
}

variable "serveo_budget_email" {
  type = string
}

variable "serveo_budget_start" {
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

resource "aws_budgets_budget" "serveo" {
  name              = "Serveo"
  budget_type       = "COST"
  limit_amount      = "8.25"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = var.serveo_budget_start

  cost_filters = {
    TagKeyValue = "user:Service$Serveo" 
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.serveo_budget_email]
  }
}


output "serveo_elastic_dns" {
  value = aws_eip.serveo.public_dns
}

output "serveo_instance_dns" {
  value = aws_instance.serveo.public_dns
}
