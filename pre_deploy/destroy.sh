#!/usr/bin/env bash
terraform init
terraform destroy -force -var-file="../default.config.tfvars"
#terraform apply service_a.tfplan

