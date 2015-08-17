# subnet for web tier

variable "web_subnet_a" { default = "10.96.41.0/24" }
variable "web_subnet_b" { default = "10.96.42.0/24" }
variable "web_subnet_c" { default = "10.96.43.0/24" }
variable "web_subnet_az_a" { default = "us-west-2a" }
variable "web_subnet_az_b" { default = "us-west-2b" }
variable "web_subnet_az_c" { default = "us-west-2c" }

resource "aws_subnet" "web_a" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.web_subnet_az_a}"
    cidr_block = "${var.web_subnet_a}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "web_a"
    }
}

resource "aws_route_table_association" "web_rt_a" {
    subnet_id = "${aws_subnet.web_a.id}"
    route_table_id = "${aws_route_table.web.id}"
}

resource "aws_subnet" "web_b" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.web_subnet_az_b}"
    cidr_block = "${var.web_subnet_b}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "web_b"
    }
}

resource "aws_route_table_association" "web_rt_b" {
    subnet_id = "${aws_subnet.web_b.id}"
    route_table_id = "${aws_route_table.web.id}"
}

resource "aws_subnet" "web_c" {
    vpc_id = "${aws_vpc.vpc.id}"
    availability_zone = "${var.web_subnet_az_c}"
    cidr_block = "${var.web_subnet_c}"
    map_public_ip_on_launch = "true"
    tags {
        Name = "web_c"
    }
}

resource "aws_route_table_association" "web_rt_c" {
    subnet_id = "${aws_subnet.web_c.id}"
    route_table_id = "${aws_route_table.web.id}"
}

output "web_subnet_a_id" { value = "${aws_subnet.web_a.id}" }
output "web_subnet_b_id" { value = "${aws_subnet.web_b.id}" }
output "web_subnet_c_id" { value = "${aws_subnet.web_c.id}" }
output "web_subnet_az_a" { value = "${var.web_subnet_az_a}" }
output "web_subnet_az_b" { value = "${var.web_subnet_az_b}" }
output "web_subnet_az_c" { value = "${var.web_subnet_az_c}" }
