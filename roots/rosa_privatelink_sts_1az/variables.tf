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
    default = "10.1.0.0/16"
    description   = "Cluster CIDR (VPC segment)"
}

variable "pubkey" {
    default = ""
    description   = "Pubkey to use in any system that requires it."
}
# Using RHEL AMIs https://access.redhat.com/solutions/15356
variable "generic_ami" {
    #default = "ami-0b2a401a8b3f4edd3" # Fedora 34 eu-central-1
    #default = "ami-086c1d77a774201ee" # Fedora 34 us-east-2
    type = map
    default = {
        ap-south-1     = "ami-05c8ca4485f8b138a"
        ap-northeast-1 = "ami-0f903fb156f24adbf"
        ap-northeast-2 = "ami-06c568b08b5a431d5"
        ap-northeast-3 = "ami-044921b7897a7e0da"
        ap-southeast-1 = "ami-0fb1ff50b2338a261"
        ap-southeast-2 = "ami-0808460885ff81045"
        ca-central-1   = "ami-0c3d3a230b9668c02"
        eu-central-1   = "ami-0e7e134863fac4946"
        eu-north-1     = "ami-06a2a41d455060f8b"
        eu-west-1      = "ami-0f0f1c02e5e4d9d9f"
        eu-west-2      = "ami-035c5dc086849b5de"
        eu-west-3      = "ami-0460bf124812bebfa"
        sa-east-1      = "ami-0c1b8b886626f940c"
        us-east-1      = "ami-06640050dc3f556bb"
        us-east-2      = "ami-092b43193629811af"
        us-west-1      = "ami-0186e3fec9b0283ee"
        us-west-2      = "ami-0bb199dd39edd7d71"
  }
    description   = "AMI to use in any system that does not belong to the cluster."
}
