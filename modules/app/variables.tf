variable "allow_ssh_cidr" { default = "0.0.0.0/0" }
variable "aws_region" { default = "us-west-2" }
variable "aws_account_id" { }
variable "ami" { }
variable "image_type" { default = "t2.micro" }
variable "cluster_min_size" { default = 1 }
variable "cluster_max_size" { default = 9 }
variable "cluster_desired_capacity" { default = 1 }
variable "keypair" { default = "app" }
variable "root_volume_size" { default = 12 }
variable "data_volume_size" { default = 12 }
variable "user_data_file" { default = "cloud-config/app" }

# networking vars set by module.vpc
variable "vpc_id" { }
variable "vpc_cidr" { }
variable "app_subnet_a_id" { }
variable "app_subnet_b_id" { }
variable "app_subnet_c_id" { }
variable "app_subnet_az_a" { }
variable "app_subnet_az_b" { }
variable "app_subnet_az_c" { }
