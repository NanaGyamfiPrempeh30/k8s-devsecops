terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate SSH key pair
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.k8s_ssh.public_key_openssh

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
  }
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.k8s_ssh.private_key_pem
  filename        = "${path.module}/k8s-key.pem"
  file_permission = "0400"
}

# Master Node (t3.small - 2GB RAM)
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.master_security_group_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-master-root"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname k8s-master
              echo "127.0.0.1 k8s-master" >> /etc/hosts
              EOF

  tags = {
    Name                                        = "${var.project_name}-master"
    Environment                                 = var.environment
    Role                                        = "master"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Worker Node 1 (t2.micro - 1GB RAM)
resource "aws_instance" "worker1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.worker_security_group_id]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-worker1-root"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname k8s-worker1
              echo "127.0.0.1 k8s-worker1" >> /etc/hosts
              EOF

  tags = {
    Name                                        = "${var.project_name}-worker1"
    Environment                                 = var.environment
    Role                                        = "worker"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Worker Node 2 (t2.micro - 1GB RAM)
resource "aws_instance" "worker2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.k8s_key.key_name
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs.worker_security_group_id]

  root_block_device {
    volume_size           = 15
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-worker2-root"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname k8s-worker2
              echo "127.0.0.1 k8s-worker2" >> /etc/hosts
              EOF

  tags = {
    Name                                        = "${var.project_name}-worker2"
    Environment                                 = var.environment
    Role                                        = "worker"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
