variable "aws_region" {
  description = "Region of the reproducible demo. Original console implementation: us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Example AZ for all three subnets; adjust as needed. This is not a claim about the original subnet AZs."
  type        = string
  default     = "us-east-1a"
}

variable "admin_ssh_cidr" {
  description = "Your current public IPv4 /32, not 0.0.0.0/0. Example: 203.0.113.10/32 is illustrative only."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ssh_cidr, 0)) && can(regex("/32$", var.admin_ssh_cidr))
    error_message = "Use a valid single-host IPv4 CIDR ending in /32."
  }
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name in the chosen region (never supply the private .pem file)."
  type        = string
  default     = "vpc-peering-recovered"
}

variable "instance_type" {
  description = "Demonstration instance size; check pricing and AWS quotas before deployment. Not verified as the original instance size."
  type        = string
  default     = "t3.micro"
}
