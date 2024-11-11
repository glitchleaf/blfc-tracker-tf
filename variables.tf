variable "hcp_org" {
  description = "The HCP organization to store state in"
}

variable "hcp_workspace" {
  description = "The workspace in the HCP organization to track the project in"
  default = "goblfc_tracker"
}
