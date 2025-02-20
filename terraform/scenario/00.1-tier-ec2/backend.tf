terraform {
  backend "s3" {
    region = "ap-northeast-2"
    bucket = "cheonkyu-atlantics-tfstate"
    key    = "provising/terraform/scenario/00.server/terraform.tfstate"
  }
}
