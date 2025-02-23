variable "name" {
  type        = string
  description = "AWS 리전"
}

variable "environment" {
  type        = string
  description = "dev/stg/prod"
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "dev/stg/prod 환경이 아님"
  }
}

variable "region" {
  type        = string
  description = "AWS 리전"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "vpc_private_subnet" {
  type        = bool
  description = "VPC private subnet 사용 유무"
  default     = false
}

variable "vpc_intra_subnet" {
  type        = bool
  description = "VPC intra subnet 사용 유무"
  default     = false
}

variable "vpc_public_subnet" {
  type        = bool
  description = "VPC public subnet 사용 유무"
  default     = false
}

variable "vpc_database_subnet" {
  type        = bool
  description = "VPC database subnet 사용 유무"
  default     = false
}

variable "nat_type" {
  type        = string
  description = "nat-instance/nat-gateway"
  validation {
    condition     = contains(["nat-instance", "nat-gateway"], var.nat_type)
    error_message = "올바른 nat_type이 아님. [nat-instance/nat-gateway]"
  }
}
