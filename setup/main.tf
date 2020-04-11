provider "aws" {
  region = var.aws_region
}

variable "jumpbox_budget_email" {
  type = string
}

variable "jumpbox_budget_start" {
  type = string
}

variable "jumpbox_key_pair" {
  type = string
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

resource "aws_key_pair" "jumpbox" {
  key_name_prefix   = "jumpbox-"
  public_key = var.jumpbox_key_pair

  tags = {
    Service = "Jumpbox"
  }
}

output "jumpbox_key_pair" {
  value = aws_key_pair.jumpbox.key_name
}
