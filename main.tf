#creating the vpc
resource "aws_vpc" "petclinic" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  #key = "terraform.tfstate"

  tags = {
    Name = var.envname
  }
}
#Public_subnets
resource "aws_subnet" "pubsubnet" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.pubsubnets,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-pubsunet-${count.index+1}"
  }
}

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
# #Private_subnets
# resource "aws_subnet" "prisubnet" {
#   vpc_id     = aws_vpc.petclinic.id
#   cidr_block = var.prisubnets

#   tags = {
#     Name = var.envname
#   }
# }

#Public_subnets
resource "aws_subnet" "prisubnets" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.prisubnets,count.index)
  availability_zone = element(var.azs,count.index)
  #map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-prisubnets-${count.index+1}"
  }
}

# #Data_subnets
# resource "aws_subnet" "datasubnet" {
#   vpc_id     = aws_vpc.petclinic.id
#   cidr_block = var.datasubnets

#   tags = {
#     Name = var.envname
#   }
# }

resource "aws_subnet" "datasubnets" {
  count = length(var.azs)
  vpc_id     = aws_vpc.petclinic.id
  cidr_block = element(var.datasubnets,count.index)
  availability_zone = element(var.azs,count.index)
  #map_public_ip_on_launch = true

  tags = {
    Name = "${var.envname}-datasubnets-${count.index+1}"
  }
}

#igw and vpc
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.petclinic.id
  tags = {
    Name = "${var.envname}-gw"
  }
}

#eip
resource "aws_eip" "natIp" {
  vpc      = true
    tags = {
    Name = "${var.envname}-natIp"
  }
}

#nat gateway in public subnet
resource "aws_nat_gateway" "natGw" {
  allocation_id = aws_eip.natIp.id
  subnet_id     = aws_subnet.pubsubnet[0].id
  tags = {
    Name = "${var.envname}-natGw"
  }
}

#route table
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
 tags = {
    Name = "${var.envname}-publicroute"
  }
}

#nat gateway
#route table - private route
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.petclinic.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGw.id
  }
 tags = {
    Name = "${var.envname}-privateroute"
  }
}

#route table - data route
resource "aws_route_table" "dataroute" {
  vpc_id = aws_vpc.petclinic.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGw.id
  }
 tags = {
    Name = "${var.envname}-dataroute"
  }
}

#association

resource "aws_route_table_association" "pubsubassociation" {
  count = length(var.pubsubnets)
  subnet_id      = element(aws_subnet.pubsubnet.*.id,count.index)
  route_table_id = aws_route_table.publicroute.id
}

resource "aws_route_table_association" "prisubassociation" {
  count = length(var.prisubnets)
  subnet_id      = element(aws_subnet.prisubnets.*.id,count.index)
  route_table_id = aws_route_table.privateroute.id
}

resource "aws_route_table_association" "datasubassociation" {
  count = length(var.datasubnets)
  subnet_id      = element(aws_subnet.datasubnets.*.id,count.index)
  route_table_id = aws_route_table.dataroute.id
}