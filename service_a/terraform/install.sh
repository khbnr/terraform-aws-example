#!/usr/bin/env bash
terraform init -backend-config="config/$1/backend.config.tfvars"
terraform plan -var-file="../../default.config.tfvars" -var-file="config/$1/config.tfvars" -out=service_a.tfplan
#terraform apply service_a.tfplan

