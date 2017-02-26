module "vpc" {
    source = "../modules/vpc"
    vpc_cidr = "10.96.0.0/16"
    vpc_name = "${var.cluster_name}"
    vpc_region = "${var.aws_account["default_region"]}"

    web_subnet_az_a  = "${var.aws_account["default_region"]}a"
    web_subnet_az_b  = "${var.aws_account["default_region"]}b"
    web_subnet_az_c  = "${var.aws_account["default_region"]}c"

    app_subnet_az_a  = "${var.aws_account["default_region"]}a"
    app_subnet_az_b  = "${var.aws_account["default_region"]}b"
    app_subnet_az_c  = "${var.aws_account["default_region"]}c"

    rds_subnet_az_a  = "${var.aws_account["default_region"]}a"
    rds_subnet_az_b  = "${var.aws_account["default_region"]}b"
    rds_subnet_az_c  = "${var.aws_account["default_region"]}c"
}
