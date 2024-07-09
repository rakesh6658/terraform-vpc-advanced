resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.common_tags,
    {
      Name = var.project_name
    },
    var.vpc_tags



  )
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags,
  { Name = var.project_name})
}
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr_block)
    vpc_id = aws_vpc.main.id
    map_public_ip_on_launch = true
    cidr_block = var.public_subnet_cidr_block[count.index]
    availability_zone = local.azs[count.index]
    tags = merge(
        var.common_tags,{
            Name = "${var.project_name}_public_${local.azs[count.index]}"
        }
        
    )
  
}
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr_block)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr_block[count.index]
    availability_zone = local.azs[count.index]
    tags = merge(
        var.common_tags,{
            Name = "${var.project_name}_private_${local.azs[count.index]}"
        }
        
    )
 
}
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr_block[count.index]
  availability_zone = local.azs[count.index]

  

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-database-${local.azs[count.index]}"
    }
  )
}
resource "aws_eip" "eip" {

  domain   = "vpc"
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.common_tags,{
  Name = var.project_name})


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ig]
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

 

  tags = merge(var.common_tags,{
    Name = "${var.project_name}-public"
  })
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

 

  tags = merge(var.common_tags,{
    Name = "${var.project_name}-private"
  })
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

 

  tags = merge(var.common_tags,{
    Name = "${var.project_name}-database"
  })
}
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
  
}
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
  
}
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
  
}
resource "aws_db_subnet_group" "database" {
  name       = "roboshop"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "My DB subnet group"
  }
}


