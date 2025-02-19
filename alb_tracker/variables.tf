variable "cidr_block" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "ingress_cidrs" {
  type = set(string)
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

variable "zone_id" {
  type = string
}
