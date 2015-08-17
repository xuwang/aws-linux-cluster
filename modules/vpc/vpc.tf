variable "vpc_cidr" { default = "10.96.3.0/16" }
variable "all_net" { default = "0.0.0.0/0" }
variable "vpc_name" { default = "cluster" }

resource "aws_vpc" "cluster" {
    cidr_block = "${var.vpc_cidr}"
    tags {
        Name = "${var.cluster_name}"
    }
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cluster" {
    vpc_id = "${aws_vpc.cluster.id}"
}


resource "aws_route_table" "web" {
    vpc_id = "${aws_vpc.cluster.id}"
    route {
        cidr_block = "${var.all_net}"
        gateway_id = "${aws_internet_gateway.cluster.id}"
    }
}

resource "aws_route_table" "app" {
    vpc_id = "${aws_vpc.cluster.id}"
    propagating_vgws = ["${vpc_gateway.vpn_gw.id}"]
    route {
        cidr_block = "${var.all_net}"
        gateway_id = "${aws_internet_gateway.cluster.id}"
    }
}

resource "aws_vpn_gateway" "vpn_gw" {
    vpc_id = "${aws_vpc.cluster.id}"

    tags {
        Name = "${var.cluster_name}"
    }
}

output "vpc_id" {
    value = "${aws_vpc.cluster.id}"
}

output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}

output "vpc_route_table" {
    value = "${aws_route_table.cluster.id}"
}

output "vpc_gateway" {
    value = "${aws_internet_gateway.cluster.id}"
}
