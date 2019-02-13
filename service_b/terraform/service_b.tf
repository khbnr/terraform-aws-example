### variables
# required
variable "aws_region" {}
variable "project" {}
variable "environment" {}
variable "backend_bucket" {}
variable "backend_lock_table" {}

### main
provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "service_a_backend" {
  backend = "s3"

  config {
    bucket = "${var.backend_bucket}"
    key    = "service-a"
    region = "${var.aws_region}"
    dynamodb_table = "${var.backend_lock_table}"
  }
}

resource "aws_s3_bucket_notification" "service_a_bucket_trigger" {
  bucket = "${data.terraform_remote_state.service_a_backend.bucket_id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.helloworld_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.helloworld_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${data.terraform_remote_state.service_a_backend.bucket_arn}"
}

data "aws_iam_policy_document" "iam_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "service_b_role" {
  name = "${var.project}_${var.environment}_demo_lambda_role_b"
  assume_role_policy = "${data.aws_iam_policy_document.iam_assume_role_policy.json}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.service_b_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# AWS Lambda function
resource "aws_lambda_function" "helloworld_lambda" {
  filename = "../lambda.zip"
  function_name = "${var.project}_${var.environment}_demo_lambda_a"
  role = "${aws_iam_role.service_b_role.arn}"
  handler = "lambda.lambdaHandleEvent"
  runtime = "nodejs8.10"
  timeout = 3
  source_code_hash = "${base64sha256(file("../lambda.zip"))}"

  tags {
    Project = "${var.project}"
    Environment = "${var.environment}"
  }
}
### output
