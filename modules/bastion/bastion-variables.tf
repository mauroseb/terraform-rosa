variable "aws_region" {
    default = "eu-central-1"
    description   = "Rosa cluster region"
}

variable "env_name" {
    default = "rosaenv"
    description   = "Environment name"
}

variable "cluster_name" {
    default = "mauro-01"
    description   = "Cluster name"
}

variable "vpc_ID" {
    description   = "VPC ID"
    default = "vpc-mauro"
    type = string
}

variable "igw_ID" {
    description   = "Internet GW ID"
    default = ""
    type = string
}

variable "ami" {
    description   = "AMI to use for the bastion instance"
    default = "ami-0b2a401a8b3f4edd3" # eu-cemtral-1
    type = string
}

variable "azs" {
    description   = "Availavility Zones"
}

variable "cluster_owner_tag" {
    default = "mauro"
    description   = "Cluster owner name to tag resources"
}

variable "pubkey" {
    default = ""
    description   = "Public key for the bastion host"
}
