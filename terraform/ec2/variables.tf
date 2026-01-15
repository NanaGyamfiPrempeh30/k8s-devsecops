variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "k8s-devsecops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "k8s-devsecops-cluster"
}

variable "master_instance_type" {
  description = "Master node instance type"
  type        = string
  default     = "t3.small"
}

variable "worker_instance_type" {
  description = "Worker node instance type"
  type        = string
  default     = "t2.micro"
}
