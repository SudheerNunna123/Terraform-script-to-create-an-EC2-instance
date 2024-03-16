provider "aws" {
  region = "your_aws_region"
}

resource "aws_instance" "example" {
  ami           = "your_ami_id"
  instance_type = "t2.micro"
  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "your_bucket_name"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_lock_table" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state_bucket.bucket
    key            = "terraform.tfstate"
    region         = "your_aws_region"
    dynamodb_table = aws_dynamodb_table.terraform_lock_table.name
  }
}
