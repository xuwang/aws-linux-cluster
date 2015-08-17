variable "vpc_cidr" { default = "10.96.3.0/16" }
variable "all_net" { default = "0.0.0.0/0" }
variable "vpc_name" { default = "cluster" }

resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "vpc-${var.vpc_name}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "igw-${var.vpc_name}"
    }
}


resource "aws_route_table" "web" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "${var.all_net}"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "rt-${var.vpc_name}-web"
    }
}

resource "aws_route_table" "app" {
    vpc_id = "${aws_vpc.vpc.id}"
    propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]
    route {
        cidr_block = "${var.all_net}"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "rt-${var.vpc_name}-app"
    }
}

resource "aws_vpn_gateway" "vgw" {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "vgw-${var.vpc_name}"
    }
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
    value = "${var.vpc_cidr}"
}

output "web_route_table" {
    value = "${aws_route_table.web.id}"
}

output "app_route_table" {
    value = "${aws_route_table.app.id}"
}

output "internet_getway" {
    value = "${aws_internet_gateway.igw.id}"
}

output "vpn_getway" {
    value = "${aws_vpn_gateway.vgw.id}"
}

