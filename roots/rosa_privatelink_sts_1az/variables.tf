variable "aws_region" {
    default = "eu-central-1"
    description   = "AWS region where to deploy."
    type = string
}

variable "env_name" {
    default = "rosaenv"
    description   = "Environment name"
    type = string
}

variable "cluster_name" {
    default = "mauro-pl"
    description   = "Cluster name"
    type = string
}

variable "cluster_owner_tag" {
    default = "mauro"
    description   = "Cluster owner name to tag resources"
    type = string
}

variable "cluster_cidr" {
    default = "10.1.0.0/24"
    description   = "Cluster CIDR (VPC segment)"
}

variable "pubkey" {
    default = ""
    description   = "Pubkey to use in any system that requires it."
}

variable "generic_ami" {
    default = "ami-0b2a401a8b3f4edd3" # Fedora 34 eu-central-1
    #default = "ami-086c1d77a774201ee" # Fedora 34 us-east-2
    description   = "Pubkey to use in any system that requires it."
}
