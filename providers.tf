provider "aws" {
  alias   = "aws-cloud"
  profile = "default"
  region  = var.aws-region
}

provider "aws" {
  profile = "default"
  region  = var.aws-region
}
