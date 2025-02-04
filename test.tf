provider "aws" {
  region = "ap-south-1"
  profile = "terradorm-user"
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

