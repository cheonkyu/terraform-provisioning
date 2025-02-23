variable "identifier" {
  type        = string
  description = "db 인스턴스명"
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
  description = "VPC id"
}

variable "cidr_block" {
  type        = string
  description = "cidr_block"
}

variable "database_subnet_group" {
  description = "database_subnet_group"
}

variable "username" {
  type        = string
  description = "db username"
}

variable "password" {
  type        = string
  description = "db password"
}
