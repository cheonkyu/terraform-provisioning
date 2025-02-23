terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "cheonkyu-atlantics-tfstate"
    key    = "provising/terraform/scenario/02.2-tiers-ec2/terraform.tfstate"
  }
}
