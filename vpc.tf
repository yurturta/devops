data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env_code
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_cidr)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-public${count.index+1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.public_cidr)
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-private${count.index+1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
   Name = var.env_code
 }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.main.id
 }

 tags = {
   Name = var.env_code
 }
}
 
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

}

#resource "aws_eip" "nat" {
#  count = length(var.public_cidr)
#  vpc = true
#
#  tags = {
#    Name = "${var.env_code}-nat${count.index+1}"
#  }
#
#}
#
#resource "aws_nat_gateway" "main" {
#  count = length(var.public_cidr)
#
#  allocation_id = aws_eip.nat[count.index].id
#  subnet_id     = aws_subnet.public[count.index].id
#
# tags = {
#   Name = "${var.env_code}-${count.index+1}"
# }
# # To ensure proper ordering, it is recommended to add an explicit dependency
# # on the Internet Gateway for the VPC.
# depends_on = [aws_internet_gateway.main]
#
#}
#
#resource "aws_route_table" "private" {
#  count = length(var.private_cidr)
#  vpc_id = aws_vpc.my_vpc.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    nat_gateway_id = aws_nat_gateway.main[count.index].id
#  }
#
#  tags = {
#    Name = "${var.env_code}-private${count.index+1}"
#  }
#}
#
#resource "aws_route_table_association" "private" {
#  count = length(var.private_cidr)
#  subnet_id      = aws_subnet.private[count.index].id
#  route_table_id = aws_route_table.private[count.index].id
#
#}

#resource "aws_network_interface" "foo" {
#  subnet_id   = aws_subnet.my_subnet.id
#  private_ips = ["172.16.10.100"]
#
#  tags = {
#    Name = "primary_network_interface"
#  }
#}
#
##resource "aws_instance" "foo" {
#  ami           = "ami-0b7fd829e7758b06d" # eu-central-1a
#  instance_type = "t2.micro"
#
#  network_interface {
#    network_interface_id = aws_network_interface.foo.id
#    device_index         = 0
#  }
#
#}