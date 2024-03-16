# Create an S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "Terraform State Bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create a DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Configure Terraform backend to use S3 and DynamoDB
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state_bucket.bucket
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = aws_dynamodb_table.terraform_lock_table.name
  }
}

# Define EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform"
  }
}
