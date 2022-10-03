locals {
   subnets = join(",", [for subnet in aws_subnet.rosa-subnet-priv: subnet.id])
}

output "bastion_ip" {
    value = <<EOF
[+] Logging to the RHEL bastion host:
ssh ec2-user@${module.bastion.bastion-ip}
EOF
    description = "Bastion access"
}

output "script" {
    value = <<EOF
[+] Create the following script and modify it at will. Run the script where rosa CLI is configured:

#!/bin/bash

REGION=${var.aws_region}
SUBNET=${local.subnets}
OWNER=${var.cluster_owner_tag}
CLUSTER_NAME=${var.cluster_name}
VERSION=4.11.5
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
