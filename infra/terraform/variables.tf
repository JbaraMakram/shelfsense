variable "aws_region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI for eu-north-1"
  default     = "ami-0989fb15ce71ba39e"
}

variable "instance_type" {
  description = "EC2 instance type — t2.micro is Free Tier"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  default     = "shelfsense-key"
}

variable "my_ip" {
  description = "Your public IP for SSH access — run: curl checkip.amazonaws.com"
  type        = string
}
