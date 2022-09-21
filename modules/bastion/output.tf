output "bastion-ip" {
    value = aws_instance.rosa-bastion.public_ip
    description = "Bastion IP address"
}