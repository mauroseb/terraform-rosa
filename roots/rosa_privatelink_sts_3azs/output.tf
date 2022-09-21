#locals {
#   length(aws_subnet.rosa-subnet-priv)
#   subnets = join(",", aws_subnet.rosa-subnet-priv[count.index]['id'])
#}

output "priv_subnet" {
    value = aws_subnet.rosa-subnet-priv[*]
    description = "Private subnet/s CIDR"
}

output "bastion_ip" {
    value = module.bastion.bastion-ip
    description = "Bastion IP address"
}

output "script" {
    value = <<EOF
Create the following script and run it where rosacli is configured:

#!/bin/bash

REGION=${var.aws_region}
SUBNET=local.subnets
OWNER=${var.cluster_owner_tag}
CLUSTER_NAME=${var.cluster_name}
VERSION=4.11.1
ROSA_ENVIRONMENT=Test

rosa create ocm-role --mode auto -y --admin
rosa create user-role --mode auto -y
rosa create account-roles --mode auto -y
time rosa create cluster --region $REGION --version $VERSION --enable-autoscaling --min-replicas 3 --max-replicas 6 --private-link --cluster-name=$CLUSTER_NAME --machine-cidr=${var.cluster_cidr} --subnet-ids=$SUBNET --tags=Owner:$OWNER,Environment:$ROSA_ENVIRONMENT --sts -y --multi-az  || exit 1
sleep 5
rosa create operator-roles --cluster $CLUSTER_NAME -y --mode auto
rosa create oidc-provider --cluster $CLUSTER_NAME -y --mode auto

echo "Follow logs with: rosa logs install -c $CLUSTER_NAME --watch"

EOF
    description = "Script to deploy cluster."
}
