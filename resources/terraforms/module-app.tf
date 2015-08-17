module "app" {
    source = "../modules/app"

    image_type = "t2.micro"
    cluster_desired_capacity = 1
    root_volume_size =  8
    docker_volume_size =  12
    keypair = "app"
    allow_ssh_cidr="0.0.0.0/0"

    # aws
    aws_account_id="${var.aws_account.id}"
    aws_region = "us-west-2"
    ami = "${lookup(var.amis, "us-west-2")}"

    # vpc
    vpc_id = "${module.vpc.vpc_id}"
    vpc_cidr = "${module.vpc.vpc_cidr}"
    app_subnet_a_id = "${module.vpc.app_subnet_a_id}"
    app_subnet_b_id = "${module.vpc.app_subnet_b_id}"
    app_subnet_c_id = "${module.vpc.app_subnet_c_id}"
    app_subnet_az_a = "${module.vpc.app_subnet_az_a}"
    app_subnet_az_b = "${module.vpc.app_subnet_az_b}"
    app_subnet_az_c = "${module.vpc.app_subnet_az_c}"
}
