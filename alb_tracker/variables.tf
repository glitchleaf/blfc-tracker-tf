variable "cidr_block" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "lb_logs_retention_days" {
  type = number
}

variable "lb_subnets" {
  type = list(string)
}

variable "logs_bucket" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "use_cloudfront" {
  type = bool
}

variable "zone_id" {
  type = string
}
