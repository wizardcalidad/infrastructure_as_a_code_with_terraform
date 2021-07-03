terraform {
    backend "s3" {
        key = "networking/dev-vpc/terraform.tfstate"
    }
}

# to initialize our backend, we use
# tarraform init -backend-config="bucket=S3_BUCKET" -backend-config="region=AWS_REGION" -backend-config="dynamodb_table=TABLE_NAME"