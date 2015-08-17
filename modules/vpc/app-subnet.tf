# subnet for app tier

variable "app_subnet_a" { default = "10.96.31.0/24" }
variable "app_subnet_b" { default = "10.96.32.0/24" }
variable "app_subnet_c" { default = "10.96.33.0/24" }
variable "app_subnet_az_a" { default = "us-west-2a" }
variable "app_subnet_az_b" { default = "us-west-2b" }
variable "app_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "app_a" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.app_subnet_az_a}"
    cidr_block = "${var.app_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "app_a"
    }
}

resource "aws_route_table_association" "app_rt_a" {
    subnet_id = "${aws_subnet.app_a.id}"
    route_table_id = "${aws_route_table.app.id}"
}

resource "aws_subnet" "app_b" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.app_subnet_az_b}"
    cidr_block = "${var.app_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "app_b"
    }
}

resource "aws_route_table_association" "app_rt_b" {
    subnet_id = "${aws_subnet.app_b.id}"
    route_table_id = "${aws_route_table.app.id}"
}

resource "aws_subnet" "app_c" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.app_subnet_az_c}"
    cidr_block = "${var.app_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "app_c"
    }
}

resource "aws_route_table_association" "app_rt_c" {
    subnet_id = "${aws_subnet.app_c.id}"
    route_table_id = "${aws_route_table.app.id}"
}

output "app_subnet_a_id" { value = "${aws_subnet.app_a.id}" }
output "app_subnet_b_id" { value = "${aws_subnet.app_b.id}" }
output "app_subnet_c_id" { value = "${aws_subnet.app_c.id}" }
output "app_subnet_az_a" { value = "${var.app_subnet_az_a}" }
output "app_subnet_az_b" { value = "${var.app_subnet_az_b}" }
output "app_subnet_az_c" { value = "${var.app_subnet_az_c}" }
