provider "aws" {
  region = "us-east-2"  # Replace with your desired region
}

resource "aws_vpc" "redshift_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "redshiftgateway" {
vpc_id = "${aws_vpc.redshift_vpc.id}"
tags = {
name = "IGW"
}
}

resource "aws_subnet" "redshift_subnet" {
  vpc_id     = aws_vpc.redshift_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table" "route" {
vpc_id = "${aws_vpc.redshift_vpc.id}"
route {
cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.redshiftgateway.id}"
}
tags = {
Name = "example"
}
}

resource "aws_route_table_association" "rt1" {
subnet_id = "${aws_subnet.redshift_subnet.id}"
route_table_id = "${aws_route_table.route.id}"
}

resource "aws_security_group" "redshift-sg" {
  name_prefix = "redshift-"
  
  vpc_id = aws_vpc.redshift_vpc.id
}

resource "aws_iam_role" "redshift_role" {
  name = "redshift-role"

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

resource "aws_iam_policy" "redshift_policy" {
  name = "redshift-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "s3:GetObject",
        Effect = "Allow",
        Resource = "arn:aws:s3:::mybucket-08-08-2023/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_attachment" {
  policy_arn = aws_iam_policy.redshift_policy.arn
  role       = aws_iam_role.redshift_role.name
}

resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier = "redshift-cluster"
  node_type         = "dc2.large"
  master_username   = "admin"
  master_password   = "Admin1234"
  cluster_subnet_group_name = aws_redshift_subnet_group.subnetgroup.name
  vpc_security_group_ids  = [aws_security_group.redshift-sg.id]
  iam_roles                = [aws_iam_role.redshift_role.arn]
}


resource "aws_redshift_subnet_group" "subnetgroup" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet.id]
}
