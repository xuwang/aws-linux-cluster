resource "aws_security_group" "web"  {
    name = "web"
    vpc_id = "${var.vpc_id}"
    description = "web"

    # Allow all outbound traffic
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Allow web peers to communicate, include web proxies
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks =  ["0.0.0.0/0"]
    }

    # Allow web2 peers to communicate, include web proxies
    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks =  ["0.0.0.0/0"]
    }

    # Allow SSH from my hosts
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_ssh_cidr}"]
      self = true
    }

    tags {
      Name = "web"
    }
}
