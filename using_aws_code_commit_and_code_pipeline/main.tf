################################################################
# VARIABLES
################################################################

variable "aws_bucket_prefix" {
  type = string
  default = "globo"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "state_bucket" {
  type = string
  description = "Name of bucket for remote state"
}

variable "dynamodb_table_name" {
  type = string
  description = "Name of dynamodb table for remote state locking"
}








################################################################
# OUTPUT
################################################################

output "code_commit_url" {
  value = aws_codecommit_repository.vpc_code.clone_url_http
}