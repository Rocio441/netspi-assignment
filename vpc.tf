resource "aws_vpc" "netspi_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "netspi_vpc"
  }
}

resource "aws_subnet" "netspi_subnet" {
  vpc_id     = aws_vpc.netspi_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "netspi_subnet"
  }
}

resource "aws_internet_gateway" "netspi_igw" {
  vpc_id = aws_vpc.netspi_vpc.id
  
  tags = {
    Name = "netspi-igw"
  }
}

# resource "aws_nat_gateway" "netspi_nat_gateway" {
#   allocation_id = data.aws_eip.existing_eip.id
#   subnet_id     = aws_subnet.netspi_subnet.id
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.netspi_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.netspi_nat_gateway.id
#   }
# }

# resource "aws_route_table_association" "private_route_table_association" {
#   subnet_id = aws_subnet.netspi_subnet.id
#   route_table_id = aws_route_table.private_route_table.id
# }

resource "aws_route_table" "netspi_route_table" {
  vpc_id = aws_vpc.netspi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.netspi_igw.id
  }

  tags = {
    Name = "netspi"
  }
}

resource "aws_route_table_association" "netspi_rt_association" {
  subnet_id      = aws_subnet.netspi_subnet.id
  route_table_id = aws_route_table.netspi_route_table.id
}

output "vpc_id" {
  value = aws_vpc.netspi_vpc.id
}