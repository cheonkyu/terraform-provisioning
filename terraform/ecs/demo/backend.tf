terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "cheonkyu-atlantics-tfstate"
    key            = "provisioning/terraform/ecs/demo/tmcd_apnortheast2/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
