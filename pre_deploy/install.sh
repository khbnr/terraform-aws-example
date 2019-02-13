#!/usr/bin/env bash
terraform init
terraform plan -var-file="../default.config.tfvars" -out=s3_backend.tfplan
#terraform apply s3_backend.tfplan
