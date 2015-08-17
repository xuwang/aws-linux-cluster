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
      from_port = 7001
      to_port = 7001
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow web2 peers to communicate, include web proxies
    ingress {
      from_port = 2380
      to_port = 2380
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow web clients to communicate
    ingress {
      from_port = 4001
      to_port = 4001
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }

    # Allow web2 clients to communicate
    ingress {
      from_port = 2379
      to_port = 2379
      protocol = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
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
