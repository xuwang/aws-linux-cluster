#
# Docker app autoscale group configurations
#
resource "aws_autoscaling_group" "app" {
  name = "app"
  availability_zones = [ "${var.app_subnet_az_a}", "${var.app_subnet_az_b}", "${var.app_subnet_az_c}"]
  min_size = "${var.cluster_min_size}"
  max_size = "${var.cluster_max_size}"
  desired_capacity = "${var.cluster_desired_capacity}"
  
  health_check_type = "EC2"
  force_delete = true
  
  launch_configuration = "${aws_launch_configuration.app.name}"
  vpc_zone_identifier = ["${var.app_subnet_a_id}","${var.app_subnet_b_id}","${var.app_subnet_c_id}"]
  
  tag {
    key = "Name"
    value = "app"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "app" {
  # use system generated name to allow changes of launch_configuration
  # name = "workder-${var.ami}"
  image_id = "${var.ami}"
  instance_type = "${var.image_type}"
  iam_instance_profile = "${aws_iam_instance_profile.app.name}"
  security_groups = [ "${aws_security_group.app.id}" ]
  key_name = "${var.keypair}"
  lifecycle { create_before_destroy = true }

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

  user_data = "${file("cloud-config/s3-cloudconfig-bootstrap.sh")}"
}

resource "aws_iam_instance_profile" "app" {
    name = "app"
    roles = ["${aws_iam_role.app.name}"]
}

resource "aws_iam_role_policy" "app_policy" {
    name = "app"
    role = "${aws_iam_role.app.id}"
    policy = "${file(\"policies/app_policy.json\")}"
}

resource "aws_iam_role" "app" {
    name = "app"
    path = "/"
    assume_role_policy =  "${file(\"policies/assume_role_policy.json\")}"
}
