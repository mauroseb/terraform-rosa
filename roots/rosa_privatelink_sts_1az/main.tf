
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "azs" {
    state = "available"
    filter {
        name   = "region-name"
        values = [var.aws_region]
    }
}

resource "aws_vpc" "rosa-vpc" {
    cidr_block           = "10.1.0.0/16"
    enable_dns_support   = "true"
    enable_dns_hostnames = "true"
    instance_tenancy     = "default"
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-vpc"
    }
}

resource "aws_subnet" "rosa-subnet-priv" {
    vpc_id                  = aws_vpc.rosa-vpc.id
    cidr_block              = "10.1.1.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = data.aws_availability_zones.azs.names[0]
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-subnet-priv"
    }
}

resource "aws_subnet" "rosa-subnet-pub" {
    vpc_id                  = aws_vpc.rosa-vpc.id
    cidr_block              = "10.1.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = data.aws_availability_zones.azs.names[0]
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-subnet-pub"
    }
}

resource "aws_internet_gateway" "rosa-igw" {
    vpc_id = aws_vpc.rosa-vpc.id
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-igw"
    }
}

resource "aws_route_table" "rosa-public-rt" {
    vpc_id = aws_vpc.rosa-vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.rosa-igw.id
    }
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-public-rt"
    }
}

resource "aws_route_table_association" "rosa-public-rta" {
    subnet_id = aws_subnet.rosa-subnet-pub.id
    route_table_id = aws_route_table.rosa-public-rt.id
}


resource "aws_eip" "rosa-eip" {
    vpc          = true
    depends_on   = [aws_internet_gateway.rosa-igw]
    tags = {
        Owner = "${var.cluster_owner_tag}"
        Name  = "${var.env_name}-subnet-1"
    }
}

resource "aws_nat_gateway" "rosa-natgw" {
    allocation_id = aws_eip.rosa-eip.id
    subnet_id     = aws_subnet.rosa-subnet-pub.id
    depends_on    = [aws_eip.rosa-eip]

    tags = {
        Owner = "${var.cluster_owner_tag}"
        Name  = "${var.env_name}-natgw"
    }

}

resource "aws_route_table" "rosa-private-rt" {
    vpc_id = aws_vpc.rosa-vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.rosa-natgw.id
    }
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-private-rt"
    }
}

resource "aws_route_table_association" "rosa-private-rta" {
    subnet_id = aws_subnet.rosa-subnet-priv.id
    route_table_id = aws_route_table.rosa-private-rt.id
}

module "bastion" {
   source            = "../../modules/bastion"
   depends_on        = [aws_vpc.rosa-vpc]
   aws_region        = var.aws_region
   ami               = var.generic_ami[var.aws_region]
   env_name          = var.env_name
   cluster_name      = var.cluster_name
   cluster_owner_tag = var.cluster_owner_tag
   vpc_ID            = aws_vpc.rosa-vpc.id
   igw_ID            = aws_internet_gateway.rosa-igw.id
   azs               = data.aws_availability_zones.azs.names[0]
   pubkey            = var.pubkey
}

