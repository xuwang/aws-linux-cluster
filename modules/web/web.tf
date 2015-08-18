#
# web cluster autoscale group configurations
#
resource "aws_autoscaling_group" "web" {
  name = "web"
  availability_zones = [ "${var.web_subnet_az_a}", "${var.web_subnet_az_b}", "${var.web_subnet_az_c}"]
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.web.name}"
  vpc_zone_identifier = ["${var.web_subnet_a_id}","${var.web_subnet_b_id}","${var.web_subnet_c_id}"]
  
  tag {
    key = "Name"
    value = "web"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "web" {
  # use system generated name to allow changes of launch_configuration
  # name = "web-${var.ami}"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.web.name}"
  security_groups = [ "${aws_security_group.web.id}" ]
  key_name = "${var.keypair}"  
  lifecycle { create_before_destroy = true }
  depends_on = [ "aws_iam_instance_profile.web", "aws_security_group.web" ]

  # /root
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.root_volume_size}" 
  }
  # /var/lib/docker
  ebs_block_device = {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "${var.data_volume_size}" 
  }
  
  user_data = "${file("${var.user_data_file}")}"
}

# setup the web ec2 profile, role and polices
resource "aws_iam_instance_profile" "web" {
    name = "web"
    roles = ["${aws_iam_role.web.name}"]
    depends_on = [ "aws_iam_role.web" ]
}

resource "aws_iam_role_policy" "web_policy" {
    name = "web_policy"
    role = "${aws_iam_role.web.id}"
    policy = "${file(\"policies/web_policy.json\")}"
    depends_on = [ "aws_iam_role.web" ]
}

resource "aws_iam_role" "web" {
    name = "web"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}



