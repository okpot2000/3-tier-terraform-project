resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })
}

# Creating internet Gateway ------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

# Creating 2 Public Subnets ----------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_public_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block [0]
  availability_zone = var.availability_zone [0]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_public_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block [1]
  availability_zone = var.availability_zone [1]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az-1c"
  })
}

# Creating 2 Private Subnets ----------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_private_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone = var.availability_zone [0]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_private_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone = var.availability_zone [1]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az-1c"
  })
}

# Creating 2 Database Subnets ----------------------------------------------------------------
resource "aws_subnet" "apci_jupiter_db_subnet_az_1a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[0]
  availability_zone = var.availability_zone [0]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1a"
  })
}

resource "aws_subnet" "apci_jupiter_db_subnet_az_1c" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_subnet_cidr_block[1]
  availability_zone = var.availability_zone [1]

 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az-1c"
  })
}

# CREATING PUBLIC ROUTE TABLE -----------------------------------------------------------------
resource "aws_route_table" "apci_jupiter_public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  })
}

# CREATING ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNETS -------------------------------------------
resource "aws_route_table_association" "public_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

resource "aws_route_table_association" "public_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_public_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_public_rt.id
}

# CREATING AN ELASTIC IP FOR AZ 1A NAT GW --------------------------------------------------------
resource "aws_eip" "eip_az_1a" {
    domain   = "vpc"
     tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1a"
  })
}

# CREATING A NAT GATEWAY FOR AZ 1A ---------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1a" {
  allocation_id = aws_eip.eip_az_1a.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1a.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1a"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1a, aws_subnet.apci_jupiter_public_subnet_az_1a]
}

# CREATING PRIVATE ROUTE TABLE FOR AZ 1A --------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1a.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt_az-1a"
  })
}

# CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ 1A -------------------------------------------------------
resource "aws_route_table_association" "private_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

resource "aws_route_table_association" "db_subnet_az_1a" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1a.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1a.id
}

# CREATING AN ELASTIC IP FOR AZ 1C NAT GW --------------------------------------------------------
resource "aws_eip" "eip_az_1c" {
    domain   = "vpc"
     tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-1c"
  })
}

# CREATING A NAT GATEWAY FOR AZ 1C ---------------------------------------------------------------
resource "aws_nat_gateway" "apci_jupiter_nat_gw_az_1c" {
  allocation_id = aws_eip.eip_az_1c.id
  subnet_id     = aws_subnet.apci_jupiter_public_subnet_az_1c.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-1c"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_1c, aws_subnet.apci_jupiter_public_subnet_az_1c]
}

# CREATING PRIVATE ROUTE TABLE FOR AZ 1C --------------------------------------------------------
resource "aws_route_table" "apci_jupiter_private_rt_az_1c" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.apci_jupiter_nat_gw_az_1c.id
  }
  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt_az-1c"
  })
}

# CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ 1C -------------------------------------------------------
resource "aws_route_table_association" "private_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_private_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}

resource "aws_route_table_association" "db_subnet_az_1c" {
  subnet_id      = aws_subnet.apci_jupiter_db_subnet_az_1c.id
  route_table_id = aws_route_table.apci_jupiter_private_rt_az_1c.id
}
