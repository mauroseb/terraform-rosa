# ROSA w/ private link and STS

The code in this repo will create the necesary AWS resources required to deploy Red Hat OpenShift Service on AWS (ROSA) cluster using private link and Secure Token Service.
It will create the cluster in a single AZ.

## Resources

### For the cluster

 * VPC
 * Public and Private subnets
 * Internet GW
 * EIP
 * NAT GW
 * Routing tables, rules and association for each subnet

### For Bastion

 * Extra subnet
 * Routing table, rules and association for bastion subnet
 * Security group
 * Public key
 * Bastion instance

## Prerequisites

 * The terraform AWS provider will need the user to be [authenticated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
 * The terraform CLI

## Deploy Environment

1. Clone this repo
```
$ git clone https://github.com/mauroseb/terraform-rosa-sts-privatelink
```
2. Create a terraform.tfvars setting values for the input variables. At least __cluster_name__ and __pubkey__.
```
$ cat terraform.tfvars
region      
cluster_name = "my-test"
pubkey = "ssh-rsa AAAAB3Nza..."
```

3. Deploy
```
$ terraform init
$ terraform plan -out "rosa.plan"
$ terraform apply "rosa.plan"
```


## Deploy Cluster

```
$ rosa create ocm-role --mode auto -y
$ rosa create user-role --mode auto -y
$ rosa create account-roles --mode auto -y
$ rosa create cluster --region eu-central-1 \
    --version 4.11.0 \
    --enable-autoscaling --min-replicas 3 --max-replicas 6 \
    --private-link \
    --cluster-name={{ cluster_name }} \
    --machine-cidr={{ vpc_cidr }} \
    --subnet-ids={{ private_subnet_id }} \
    --sts -y




