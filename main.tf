##########################################
#Provider info
##########################################
provider "aws" {
  region = "ap-south-1"
  
}
data "aws_availability_zones" "available" {  
}
############################################
#Variables
###########################################
variable "Development" { 
default = "True"
}

#################################################
#Creation of VPC
#################################################
resource "aws_vpc" "main" {
  cidr_block       = "10.100.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
	Environment = "STG"
	Terraform = "True"
  Phase = "${var.Development}-Phase"
  }
}

##################################################
#Creation of public subnet
##################################################
resource "aws_subnet" "public-1a" {
  cidr_block = "10.100.2.0/24"
  vpc_id = "${aws_vpc.main.id}"
  map_public_ip_on_launch = "true"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
    tags  = {
      Name = "Public-1a"
      Terraform = "True"
      #AZ = "${data.aws_availabilty_zones.available.names[0]}"
    }
}
#################################################
#Creation of private subnet
##############################################
resource "aws_subnet" "private-1a" {
  cidr_block = "10.100.50.0/24"
  map_public_ip_on_launch = "false"
  vpc_id = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
    tags  = {
      Name = "Private-1b"
      Terraform = "True"
    }
}
#####################################
#create internet gate way
#####################################
resource "aws_internet_gateway" "manojigw" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name = "Manoj-IGW"
    Terraform = "True"
  }
}
#####################################
#create elastic ip for NAT gateway
#####################################
resource "aws_eip" "NAT-Elasticip" {
  vpc = true
  tags = {
    Name = "Manoj-EIP"
    Terraform = "True"
  }
}

#####################################
#create of NAT gateway
#####################################
resource "aws_nat_gateway" "TerraformNAT" {
  allocation_id = "${aws_eip.NAT-Elasticip.id}"
  subnet_id = "${aws_subnet.public-1a.id}"
  tags = {
    Name = "Manoj-NAT"
    Terraform = "True"
  }
}


#####################################
#create route table for public subnet
#####################################
resource "aws_route_table" "rtbpublic1a" {
  vpc_id = "${aws_vpc.main.id}"
    route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.manojigw.id}"
    }
    tags = {
      Name = "Public-1a"
      Terraform = "True"
    }
}
##############################################
#Associate public route table for public subnet
##############################################
resource "aws_route_table_association" "publicttassoc" {
  subnet_id = "${aws_subnet.public-1a.id}"
  route_table_id = "${aws_route_table.rtbpublic1a.id}"
}

#####################################
#create route table for private subnet
#####################################
resource "aws_route_table" "rtprivate1a" {
  vpc_id = "${aws_vpc.main.id}"
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.TerraformNAT.id}"
  }
  tags = {
    Name = "Private-1a"
    Terraform = "True"
  }
}

##############################################
#Associate public route table for public subnet
##############################################
resource "aws_route_table_association" "privatettassoc" {
  subnet_id = "${aws_subnet.private-1a.id}"
  route_table_id = "${aws_route_table.rtprivate1a.id}"
}

##########################################
#Creation of security group for web server
##########################################
resource "aws_security_group" "BastonSG" {
  description = "Allow SSH for baston server"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "manojprovatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "manojgenerated_key" {
  key_name   = "Bastonkey"
  public_key = "${tls_private_key.manojprovatekey.public_key_openssh}"
}
##########################################
#Creation of EC2-Instance
##########################################
resource "aws_instance" "baston" {
  ami = "ami-0b99c7725b9484f9e"
  instance_type = "t2.micro"
  count = 1
  associate_public_ip_address = "true"
  disable_api_termination = "false"
  ipv6_address_count = "0"
  subnet_id = "${aws_subnet.public-1a.id}"
  key_name = "${aws_key_pair.manojgenerated_key.key_name}"
  monitoring = "false"
  security_groups = ["${aws_security_group.BastonSG.id}"]
    tags = {
      Name = "Baston"
      Terraform = "True"
    }
}

