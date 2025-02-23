variable "region" {
  default     = "ap-northeast-2"
  description = "AWS 리전"
}

variable "name" {
  default     = "my-2-tier-ec2"
  description = "AWS 리전"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR"
}

variable "environment" {
  default     = "dev"
  description = "dev/stg/prod"
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "dev/stg/prod 환경이 아님"
  }
}
