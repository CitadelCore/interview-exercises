resource "aws_vpc" "default" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_subnet" "public_1" {
    cidr_block = "10.0.1.0/24"
    vpc_id = aws_vpc.default.id
    availability_zone = local.availability_zones[0]
}

resource "aws_subnet" "public_2" {
    cidr_block = "10.0.2.0/24"
    vpc_id = aws_vpc.default.id
    availability_zone = local.availability_zones[1]
}

resource "aws_subnet" "private_1" {
    cidr_block = "10.0.3.0/24"
    vpc_id = aws_vpc.default.id
    availability_zone = local.availability_zones[0]
}

resource "aws_subnet" "private_2" {
    cidr_block = "10.0.4.0/24"
    vpc_id = aws_vpc.default.id
    availability_zone = local.availability_zones[1]
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "public_1" {
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public_1.id
}

resource "aws_route_table_association" "public_2" {
    route_table_id = aws_route_table.public.id
    subnet_id = aws_subnet.public_2.id
}

resource "aws_route_table_association" "private_1" {
    route_table_id = aws_route_table.private.id
    subnet_id = aws_subnet.private_1.id
}

resource "aws_route_table_association" "private_2" {
    route_table_id = aws_route_table.private.id
    subnet_id = aws_subnet.private_1.id
}

resource "aws_eip" "gateway" {
    vpc = true
    associate_with_private_ip = "10.0.0.5"
    depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
    allocation_id = aws_eip.gateway.id
    subnet_id = aws_subnet.public_1.id
    depends_on = [aws_eip.gateway]
}

resource "aws_route" "gateway_private" {
    route_table_id = aws_route_table.private.id
    nat_gateway_id = aws_nat_gateway.default.id
    destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "default" {
    vpc_id = aws_vpc.default.id
}

resource "aws_route" "gateway_public" {
    route_table_id = aws_route_table.public.id
    gateway_id = aws_internet_gateway.default.id
    destination_cidr_block = "0.0.0.0/0"
}
