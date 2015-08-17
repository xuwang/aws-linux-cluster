module "web" {
    source = "../modules/web"

    # web cluster_desired_capacity should be in odd numbers, e.g. 3, 5, 9
    cluster_desired_capacity = 1
    image_type = "t2.micro"
    keypair = "web"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "us-west-2"
    ami = "${lookup(var.amis, "us-west-2")}"

    # Note: currently web launch_configuration devices can NOT be changed after web cluster is up
    # See https://github.com/hashicorp/terraform/issues/2910
    docker_volume_size = 12
    root_volume_size = 12

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"
    web_subnet_a_id = "${module.vpc.web_subnet_a_id}"
    web_subnet_b_id = "${module.vpc.web_subnet_b_id}"
    web_subnet_c_id = "${module.vpc.web_subnet_c_id}"
    web_subnet_az_a = "${module.vpc.web_subnet_az_a}"
    web_subnet_az_b = "${module.vpc.web_subnet_az_b}"
    web_subnet_az_c = "${module.vpc.web_subnet_az_c}"

}
