variable "concat_base_uri" {
  description = "URL for the ConCat instance we're paired with"
  type        = string
}

variable "domain_name" {
  description = "Domain name to use for tracker (eg: tracker.furcon.org)"
  type        = string
}

variable "smtp_email" {
  description = "The sender address on outbound emails"
  type        = string
}

variable "smtp_name" {
  description = "The sender name on outbound emails"
  type        = string
}

variable "lb_zones" {
  description = "How many availibility zones to have the load balancer listening in (min is 2)"
  default     = 2
  type        = number
}

variable "tracker_image" {
  description = "Docker image tag for Tracker itself, should be a prefix for the two images (nginx and app)"
  default     = "ghcr.io/glitchleaf/blfc-tracker-tf"
  type        = string
}

variable "tracker_spec_cpu" {
  description = "How many vCPUs to allocate per instance of Tracker (1024 == 1 vCPU)"
  default     = 256
  type        = number
}

variable "tracker_spec_memory" {
  description = "How much memory to allocate per instance of Tracker (in megabytes)"
  default     = 512
  type        = number
}

variable "vpc_name" {
  description = "Name of the VPC to run our stuff in, leave as default to have one created with 10.0.0.0/16"
  default     = "default"
  type        = string
}
