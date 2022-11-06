resource "aws_subnet" "bastion-subnet" {
    vpc_id                  = var.vpc_ID
    cidr_block              = "10.1.10.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = var.azs
    tags                    = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-bastion-subnet"
    }
}

resource "aws_route_table" "bastion-rt" {
    vpc_id = var.vpc_ID
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"
        gateway_id = var.igw_ID
    }
    tags = {
        Owner = var.cluster_owner_tag
        Name = "${var.env_name}-bastion-rt"
    }
}

resource "aws_route_table_association" "bastion-rta" {
    subnet_id = aws_subnet.bastion-subnet.id
    route_table_id = aws_route_table.bastion-rt.id
}

resource "aws_key_pair" "bastion-keypair" {
    key_name   = "${var.env_name}-bastion-keypair"
    public_key = var.pubkey
    tags       = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-bastion-keypair"
    }
}

resource "aws_security_group" "bastion-sg" {
    name        = "${var.env_name}-bastion-sg"
    description = "Allow SSH inbound traffic"
    vpc_id      = var.vpc_ID
    tags        = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-bastion-sg"
    }
    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

}

resource "aws_instance" "rosa-bastion" {
    ami                           = var.ami 
    associate_public_ip_address   = true
    instance_type                 = "t3.micro"
    private_ip                    = "10.1.10.10"
    key_name                      = aws_key_pair.bastion-keypair.key_name
    subnet_id                     = aws_subnet.bastion-subnet.id
    vpc_security_group_ids        = [aws_security_group.bastion-sg.id]
    user_data                     = templatefile("${path.module}/templates/user_data.sh.tftpl", {username = "ec2-user"})
    tags                          = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-bastion"
    }
    credit_specification {
        cpu_credits = "unlimited"
    }
}
