variable "vpc_name" {
  type    = string
  default = "Test Vpc"
}

variable "sg_name" {
  type    = string
  default = "EC2-test-access"
}

variable "sg_ingress" {
  type    = string
  default = "HTTPS ingress"
}