variable "name_prefix" {
  description = "Prefix used for naming all resources in this module"
  type        = string
  default     = "StackGuardian"
}

variable "server_port" {
  description = "The port for HTTP requests"
  type        = number
  default     = 8080
}

variable "instance_type" {
    description = "Instance type for the server"
    type = string
    default = "t2.micro"
}

variable "ami_id" {
    description = "AMI for the instance use, if left empty Amazon Linux AMI will be taken"
    type = string
    default = ""
}

variable "key_name" {
    description = "Name of the Key Pair you create per App"
    type = string
    default = "Fancy_Key"
}


variable "repo_name" {
  description = "The name of the GitHub Repo containing React Code"
  type        = string
  default     = "ReactCalculator"
}

# variable "launch_config_name" {
#   description = "The name of the Launch Config obtained from the launch config module"
#   type        = string
#   default     = "NoDefaultAvailable"
# }

variable "public_subnets" {
  type        = list(string)
  description = "ID for public subnets."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where bastion hosts and security groups will be created."
}