module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.96.0.0/16"
    vpc_name = "${var.cluster_name}"
}
