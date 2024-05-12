# main.tf

provider "aws" {
  region = "us-west-2"  # Change to your desired AWS region
}

# Creating an SSH key pair
resource "tls_private_key" "quivrapp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "quivrapp" {
  key_name   = "quivrapp"
  public_key = tls_private_key.quivrapp.public_key_openssh
}

# Creating VPC, subnets, and security group
resource "aws_vpc" "quivrapp" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "quivrapp" {
  vpc_id            = aws_vpc.quivrapp.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "quivrapp_2" {
  vpc_id            = aws_vpc.quivrapp.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

resource "aws_security_group" "quivrapp" {
  vpc_id = aws_vpc.quivrapp.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = "eks-quivr-dev"
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.quivrapp.id, aws_subnet.quivrapp_2.id]
    security_group_ids = [aws_security_group.quivrapp.id]
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "workers"

  node_role_arn = aws_iam_role.node_role.arn

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.quivrapp.key_name
  }

  subnet_ids         = [aws_subnet.quivrapp.id, aws_subnet.quivrapp_2.id]
  security_group_ids = [aws_security_group.quivrapp.id]
}

resource "aws_iam_role" "cluster_role" {
  name = "my-eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "node_role" {
  name = "my-eks-node-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ec2_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}