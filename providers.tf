provider "aws" {
  alias   = "aws-cloud"
  profile = "default"
  region  = var.aws-region
}

provider "aws" {
  profile = "default"
  region  = var.aws-region
}

terraform {
  backend "s3" {
    bucket = "terraform-tf-state"
    key    = "cluster-state/remote-state"
    region = "us-west-1"
  }
}
