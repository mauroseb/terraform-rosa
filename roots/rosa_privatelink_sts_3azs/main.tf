
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
    for_each                = toset(data.aws_availability_zones.azs.names)
    depends_on              = [aws_vpc.rosa-vpc]
    vpc_id                  = aws_vpc.rosa-vpc.id
    cidr_block              = "10.1.1${index(data.aws_availability_zones.azs.names, each.value) + 1}.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = each.value
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-subnet-priv-${each.key}"
    }
}

resource "aws_subnet" "rosa-subnet-pub" {
    for_each                = toset(data.aws_availability_zones.azs.names)
    depends_on              = [aws_vpc.rosa-vpc]
    vpc_id                  = aws_vpc.rosa-vpc.id
    cidr_block              = "10.1.2${index(data.aws_availability_zones.azs.names, each.value) + 1}.0/24"
    map_public_ip_on_launch = "false"
    availability_zone       = each.value
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-subnet-pub-${each.key}"
    }
}

resource "aws_internet_gateway" "rosa-igw" {
    vpc_id = aws_vpc.rosa-vpc.id
    tags = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-igw"
    }
}

resource "aws_route_table" "rosa-public-rt" {
    for_each     = toset(data.aws_availability_zones.azs.names)
    vpc_id       = aws_vpc.rosa-vpc.id
    depends_on   = [aws_internet_gateway.rosa-igw]
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.rosa-igw.id
    }
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-public-rt-${each.value}"
    }
}

resource "aws_route_table_association" "rosa-public-rta" {
    for_each  = toset(data.aws_availability_zones.azs.names)
    subnet_id = aws_subnet.rosa-subnet-pub[each.value].id
    route_table_id = aws_route_table.rosa-public-rt[each.value].id
}

resource "aws_eip" "rosa-eip" {
    for_each     = toset(data.aws_availability_zones.azs.names)
    vpc          = true
    depends_on   = [aws_internet_gateway.rosa-igw]
    tags = {
        Owner = "${var.cluster_owner_tag}"
        Name  = "${var.env_name}-eip-${each.value}"
    }
}

resource "aws_nat_gateway" "rosa-natgw" {
    for_each      = toset(data.aws_availability_zones.azs.names)
    allocation_id = aws_eip.rosa-eip[each.value].id
    subnet_id     = aws_subnet.rosa-subnet-pub[each.value].id
    //depends_on    = [aws_eip.rosa-eip[each.value]]

    tags = {
        Owner = "${var.cluster_owner_tag}"
        Name  = "${var.env_name}-natgw"
    }

}

resource "aws_route_table" "rosa-private-rt" {
    for_each  = toset(data.aws_availability_zones.azs.names)
    vpc_id    = aws_vpc.rosa-vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.rosa-natgw[each.value].id
    }
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-private-rt-${each.value}"
    }
}

resource "aws_route_table_association" "rosa-private-rta" {
    for_each       = toset(data.aws_availability_zones.azs.names)
    subnet_id      = aws_subnet.rosa-subnet-priv[each.value].id
    route_table_id = aws_route_table.rosa-private-rt[each.value].id
}

module "bastion" {
   source            = "../../modules/bastion"
   depends_on        = [aws_vpc.rosa-vpc]
   aws_region        = var.aws_region
   ami               = var.generic_ami[${var.aws_region}]
   env_name          = var.env_name
   cluster_name      = var.cluster_name
   cluster_owner_tag = var.cluster_owner_tag
   vpc_ID            = aws_vpc.rosa-vpc.id
   igw_ID            = aws_internet_gateway.rosa-igw.id
   azs               = data.aws_availability_zones.azs.names[0]
   pubkey            = var.pubkey
}

