data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "k8s-devsecops-tfstate-bucket"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Get latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
