# Define the provider and region
provider "aws" {
  access_key = ""
  secret_key = ""
  # Replace with your desired AWS region
  region = "us-east-1"  
}

# Create a VPC
resource "aws_vpc" "DP5-1_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "D5.1_VPC"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "DP5-1_igw" {
  vpc_id = aws_vpc.DP5-1_vpc.id
  tags = {
    Name = "D5.1_VPC_igw"
  }
}

# Create two subnets in two AZs
resource "aws_subnet" "subnet1" {
  count = 3
  vpc_id = aws_vpc.DP5-1_vpc.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "us-east-1${element(["a", "b" , "b"], count.index)}"
  map_public_ip_on_launch = true
}

# Create a security group with rules for ports 8080, 8000, and 22
resource "aws_security_group" "DP5-1_security_group" {
  name        = "D5.1_SG"
  description = "Security Group for Deployment 5.1"
  vpc_id      = aws_vpc.DP5-1_vpc.id

}

# Create an inbound rule for ingress
resource "aws_security_group_rule" "ingress_rules" {
  count = 3
  type = "ingress"
  from_port = element([8080, 8000, 22], count.index)
  to_port = element([8080, 8000, 22], count.index)
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.DP5-1_security_group.id
}

# Create an outbound rule for egress
resource "aws_security_group_rule" "egress_rule" {
  type = "egress"
  from_port = 0
  to_port = 0  # Allow all outbound traffic
  protocol = "-1"  # All protocols
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.DP5-1_security_group.id
}

# Create a route to the Internet Gateway for public subnets
resource "aws_route" "internet_route" {
  route_table_id         = aws_vpc.DP5-1_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.DP5-1_igw.id
}

# Launch two EC2 instances in the public subnets
resource "aws_instance" "my_ec2_instances" {
  count           = 3
  ami             = "ami-053b0d53c279acc90"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.DP5-1_security_group.id]
  subnet_id       = aws_subnet.subnet1[count.index].id
  key_name        = "DepKeys"
  user_data       = count.index == 0 ? file("deploy.sh") : null
  tags = count.index == 0 ? { Name = "D5.1_Jenkins_EC2" } : count.index == 1 ? { Name = "D5.1_AppServer1_EC2" } : { Name = "D5.1_AppServer2_EC2" }
}
