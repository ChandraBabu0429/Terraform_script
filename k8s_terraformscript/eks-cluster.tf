resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.26" # Ensure this version is supported

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet1.id,
      aws_subnet.subnet2.id
    ]
  }
}

resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  instance_types  = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

 
}

