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
    user_data = <<EOF
#!/bin/bash

dnf -e 0 -q -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -e 0 -q -y install git iperf3 podman wget jq bind-utils make zsh net-tools
wget -q https://github.com/mikefarah/yq/releases/download/v4.27.5/yq_linux_amd64.tar.gz -O - | tar xvzf - -C /usr/local/bin --strip-components=0 ./yq_linux_amd64
mv /usr/local/bin/yq_linux_amd64 /usr/local/bin/yq
wget -q https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
curl -sSL4 https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64 -o /usr/local/bin/helm && chmod +x /usr/local/bin/helm
tar xzf openshift-client-linux.tar.gz kubectl oc && rm openshift-client-linux.tar.gz
mv oc kubectl /usr/local/bin/

sudo -u ec2-user -i bash <<_EC2USER_
id -a
git clone https://github.com/mauroseb/dotfiles.git
cd dotfiles ; make all; cd
usermod -s `which zsh` ec2-user
exit
_EC2USER_


EOF
    tags                          = {
        Owner = var.cluster_owner_tag
        Name  = "${var.env_name}-bastion"
    }
    credit_specification {
        cpu_credits = "unlimited"
    }
}
