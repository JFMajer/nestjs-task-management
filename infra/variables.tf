variable "app_name" {
  type    = string
  default = "#{APP_NAME}#"
}

variable "vpc_cidr" {
  type    = string
  default = "10.23.0.0/16"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "db_password" {
  type    = string
  default = "#{DB_PASSWORD}#"
}