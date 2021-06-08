variable "region" {
        default = "us-east-1"
}

variable "profile" {
    description = "AWS credentials profile you want to use"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "server_port" {
    description = "The port the server will use for HTTP requests"
    default = 8080
}