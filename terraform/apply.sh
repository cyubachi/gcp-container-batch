#!/bin/bash -eu

cd $(dirname ${0})

terraform apply --auto-approve -input=false tfplan
