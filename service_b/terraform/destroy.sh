#!/usr/bin/env bash
terraform init -backend-config="config/$1/backend.config.tfvars"
terraform destroy -force -var-file="../../default.config.tfvars" -var-file="config/$1/config.tfvars"
#terraform apply service_a.tfplan

