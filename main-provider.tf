provider "aws" {
  region     = "${var.region}"
}
# How to store Terraform state file in S3 Bucket | How to manage Terraform state in S3 Bucket
#1 -this will create a S3 bucket in AWS
resource "aws_s3_bucket" "terraform_state_s3" {
  #make sure you give unique bucket name
  bucket = "terraform-coachdevops-b-state" 
  force_destroy = true
# Enable versioning to see full revision history of our state files
  versioning {
         enabled = true
        }

# Enable server-side encryption by default
server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# 2 - this Creates Dynamo Table
resource "aws_dynamodb_table" "terraform_locks" {
# Give unique name for dynamo table name
  name         = "tf-up-on-and-run-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
        attribute {
         name = "LockID"
         type = "S"
      }
}

#Step 3 - Creates S3 backend
terraform {
  backend "s3" {
    #Replace this with your bucket name!
    bucket         = "terraform-coachdevops-b-state"
    key            = "dc/s3/terraform.tfstate"
    region         = "us-east-1"
    #Replace this with your DynamoDB table name!
    dynamodb_table = "tf-up-on-and-run-locks"
    encrypt        = true
    }
}