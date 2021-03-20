terraform {
  backend "s3" {
    bucket = "mhdez"
    key    = "terraform/cann/terraform.tfstate"
    region = "eu-west-1"
  }
}
