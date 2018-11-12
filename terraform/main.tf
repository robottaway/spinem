provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "spinem" {
  cidr_block = "10.5.0.0/16"

  tags {
    Name = "spinem"
  }
}

## Gateway

resource "aws_internet_gateway" "spinem" {
  vpc_id = "${aws_vpc.spinem.id}"

  tags {
    Name = "spinem"
  }
}

## Subnetting

resource "aws_subnet" "pub1" {
  vpc_id     = "${aws_vpc.spinem.id}"
  cidr_block = "10.5.1.0/24"

  tags {
    Name = "spinem_pub1"
  }
}

resource "aws_subnet" "priv1" {
  vpc_id     = "${aws_vpc.spinem.id}"
  cidr_block = "10.5.2.0/24"

  tags {
    Name = "spinem_priv1"
  }
}

resource "aws_eip" "spinem_nat" {
  vpc = true
}

## NAT

resource "aws_nat_gateway" "spinem" {
  allocation_id = "${aws_eip.spinem_nat.id}"
  subnet_id     = "${aws_subnet.pub1.id}"

  depends_on = ["aws_internet_gateway.spinem"]

  tags {
    Name = "Spinem NAT"
  }
}

## Routing Tables

resource "aws_route_table" "spinem_default_rt" {
  vpc_id = "${aws_vpc.spinem.id}"

  tags {
    Name = "spinem default table"
  }
}

resource "aws_route" "spinem_r_nat" {
    route_table_id = "${aws_route_table.spinem_default_rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.spinem.id}"
  }

resource "aws_route_table" "spinem_secondary_rt" {
  vpc_id = "${aws_vpc.spinem.id}"

  tags {
    Name = "spinem second table"
  }
}

resource "aws_route" "spinem_r_igw" {
  route_table_id               = "${aws_route_table.spinem_secondary_rt.id}"
  gateway_id      = "${aws_internet_gateway.spinem.id}"
  destination_cidr_block    = "0.0.0.0/0"
}

resource "aws_main_route_table_association" "spinem_default_rt_a" {
  vpc_id         = "${aws_vpc.spinem.id}"
  route_table_id = "${aws_route_table.spinem_default_rt.id}"
}

resource "aws_route_table_association" "spinem_secondary_rt_a" {
  subnet_id      = "${aws_subnet.pub1.id}"
  route_table_id = "${aws_route_table.spinem_secondary_rt.id}"
}

resource "aws_default_security_group" "spinem_default" {
  vpc_id = "${aws_vpc.spinem.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
