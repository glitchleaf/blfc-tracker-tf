variable "external_name" {
  description = "The domain users will talk to"
  type        = string
}

variable "internal_name" {
  description = "The domain cloudflare will forward user traffic to"
  type        = string
}
