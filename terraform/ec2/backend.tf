terraform {
  backend "s3" {
    bucket         = "k8s-devsecops-tfstate-bucket"
    key            = "ec2/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "k8s-devsecops-tfstate-lock"
    encrypt        = true
  }
}
