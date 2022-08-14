####### Create a EC2 Instance with VPN TailScale ########
resource "aws_instance" "vpn" {
  instance_type               = "t2.micro"
  ami                         = "ami-051dfed8f67f095f5"
  #key_name                   = aws_key_pair.key_pair.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_role.name
  vpc_security_group_ids      = [aws_security_group.vpn.id]
  subnet_id                   = aws_subnet.private_admin.*.id[0]
  
  tags = {
    Name = "TailScale-Main-VPN"
  }

  user_data = <<EOF
  #!bin/bash
  sudo apt update -y
  sudo apt upgrade -y
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
  sudo apt update -y
  sudo apt install tailscale -y
  EOF

  root_block_device {
    volume_size = 10
  }
}

# Create and assosiate an Elastic IP
resource "aws_eip" "vpn" {
  instance                    = aws_instance.vpn.id
  vpc                         = true
}
