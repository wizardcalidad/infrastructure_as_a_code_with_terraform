provider "aws" {
    region = "us-east-1"

    assume_role {
      role_arn = "arn:aws:iam::123456789012:role/iac"
    }
}

module "mymodule" {
    source = "./modules/my_module"
    variable1 = "value1"
    variable2 = "value2"
}
