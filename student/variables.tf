variable "location" {
  default = "eastus"
}

variable "count" {
  default = 3
}

variable log-analytics-workspace-sku {
  default = "PerGB2018"
}

variable "ssh-public-key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "tags" {
  type    = "map"
  default = {}
}
