variable "name" {
  type        = string
  description = "서버명"
}

variable "environment" {
  type        = string
  description = "dev/stg/prod"
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "dev/stg/prod 환경이 아님"
  }
}

variable "vpc_id" {
  type        = string
  description = "vpc_id"
}

variable "private_subnets" {
  description = "private_subnets"
}

variable "private_subnets_cidr_blocks" {
  description = "private_subnets_cidr_blocks"
}
