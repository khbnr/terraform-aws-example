variable "aws_region" {}
variable "project" {}
variable "environment" {
  default = "dev"
}
variable "backend_bucket_name" {
  default = "khbnr-demo-tf-backend-dev"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_s3_bucket" "state_backend" {
  bucket = "${var.backend_bucket_name}"

  versioning {
    enabled = false
  }

  force_destroy = true

  tags {
    Project = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock_tables" {
  name           = "${var.project}-${var.environment}-backend-lock"
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Project = "${var.project}"
    Environment = "${var.environment}"
  }
}

output "dynamodb_table" {
  value = "${aws_dynamodb_table.terraform_state_lock_tables.id}"
}

output "bucket" {
  value = "${aws_s3_bucket.state_backend.id}"
}
