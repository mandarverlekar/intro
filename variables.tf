variable "vpc-cidr" {
  description = "Value for cidr"
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "Value for as region"
  default     = "us-east-1"
}

variable "public-subnet-1" {
  description = "Value for public subnet-1"
  default     = "10.0.1.0/24"
}

variable "public-subnet-2" {
  description = "Value for public subnet-2"
  default     = "10.0.2.0/24"
}

variable "az-1" {
  description = "Value for as AWS AZ"
  default     = "us-east-1a"
}

variable "az-2" {
  description = "Value for as AWS AZ"
  default     = "us-east-1b"
}

variable "ami" {
  description = "Value for EC2 ami"
  default     = "ami-04a81a99f5ec58529"
}

variable "instance-type" {
  description = "Value for EC2 instance-type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Value for key name"
  default     = "aws_poc2"
}
