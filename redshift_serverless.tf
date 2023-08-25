provider "aws" {
  region = "us-east-2"  # Replace with your desired region
}

resource "aws_vpc" "redshift_serverless_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
name = "Redshift-vpc"
}
}
resource "aws_internet_gateway" "redshiftgateway" {
vpc_id = "${aws_vpc.redshift_serverless_vpc.id}"
tags = {
name = "IGW"
}
}
resource "aws_security_group" "redshift-sg" {
  name_prefix = "redshift-"
  vpc_id = "${aws_vpc.redshift_serverless_vpc.id}"
  tags = {
name = "redshift-sg"
}
}

resource "aws_subnet" "redshift_subnet1" {
  vpc_id     = aws_vpc.redshift_serverless_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
name = "redshift-subnet1"
}
}

resource "aws_subnet" "redshift_subnet2" {
  vpc_id     = aws_vpc.redshift_serverless_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
name = "redshift-subnet2"
}
}

resource "aws_iam_role" "redshift_role" {
  name = "RedshiftRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_redshift_parameter_group" "redshift_parameter_group" {
  name   = "parameter-group-test-terraform"
  family = "redshift-1.0"
  tags = {
name = "redshift-parameter-group"
}
}
resource "aws_redshiftserverless_namespace" "redshift-namespace" {
  namespace_name = "redshift-namespace"
  
}
resource "aws_redshiftserverless_workgroup" "redshift-workgroup" {
  namespace_name = "redshift-namespace"
  workgroup_name = "redshift-workgroup"
}

resource "aws_redshift_subnet_group" "redshift_subnetgroup" {
  name       = "my-redshift-subnetgroup"
  subnet_ids = [aws_subnet.redshift_subnet1.id, aws_subnet.redshift_subnet2.id]

  tags = {
    environment = "Production"
  }
}

resource "aws_redshift_cluster" "redshift_serverless" {
  cluster_identifier        = "my-redshift-cluster"
  database_name             = "mydb"
  master_username          = "admin"
  master_password          = "Admin1234"
  node_type                = "dc2.large"
  number_of_nodes          = 2

  iam_roles                = [aws_iam_role.redshift_role.arn]
  cluster_parameter_group_name = aws_redshift_parameter_group.redshift_parameter_group.name
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnetgroup.name
  vpc_security_group_ids   = [aws_security_group.redshift-sg.id]
  enhanced_vpc_routing     = true  # Enable Enhanced VPC Routing
  
  # Other cluster configurations...

  tags = {
    Name = "MyRedshiftCluster"
  }
}

output "cluster_endpoint" {
  value = aws_redshift_cluster.redshift_serverless.endpoint
}
