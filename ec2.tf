resource "aws_efs_file_system" "netspi_efs" {
  creation_token = "netspi_efs"
  encrypted = true
  tags = {
    Name = "netspi_efs"
  }
}

resource "aws_security_group" "netspi_sg" {
  name        = "netspi_sg"
  description = "Allow NFS traffic and SSH traffic"
  vpc_id      = aws_vpc.netspi_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_mount_target" "netspi_mount_target" {
  file_system_id = aws_efs_file_system.netspi_efs.id
  subnet_id      = aws_subnet.netspi_subnet.id
  security_groups = [aws_security_group.netspi_sg.id]
}

data "aws_eip" "existing_eip" {
  filter {
    name   = "tag:Project"
    values = ["NetSPI_EIP"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa sample key"
}

resource "aws_instance" "netspi_ec2" {
  ami           = "ami-0182f373e66f89c85" 
  instance_type = "t2.micro"

  subnet_id = aws_subnet.netspi_subnet.id
  vpc_security_group_ids = [aws_security_group.netspi_sg.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-efs-utils
              mkdir -p /data/test
              mount -t efs ${aws_efs_file_system.netspi_efs.id}:/ /data/test
              EOF

  tags = {
    Name = "netspi-ec2"
  }
}

resource "aws_eip_association" "netspi_eip_association" {
  instance_id   = aws_instance.netspi_ec2.id
  allocation_id = data.aws_eip.existing_eip.id
}

output "efs_id" {
  description = "The EFS File System ID"
  value       = aws_efs_file_system.netspi_efs.id
}

output "ec2_details" {
    description = "The EC2 Id"
    value = aws_instance.netspi_ec2.id
}

output "SG_id" {
    description = "SG-id"
    value = aws_security_group.netspi_sg.id  
}


output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = data.aws_eip.existing_eip.public_ip
}