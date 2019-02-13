### variables
# required
variable "aws_region" {}
variable "project" {}
variable "environment" {}

# optional

### main
provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "service_a_bucket" {
  bucket = "${replace(var.project, "_", "-l")}-${var.environment}-service-a"

  versioning {
    enabled = false
  }

  tags {
    Project = "${var.project}"
    Environment = "${var.environment}"
  }
}

### output
output "bucket_id" {
  value = "${aws_s3_bucket.service_a_bucket.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.service_a_bucket.arn}"
}
