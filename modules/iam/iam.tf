# deployment user for elb registrations etc.
resource "aws_iam_user" "deployment" {
    name = "${var.deployment_user}"
    path = "/system/"
}
resource "aws_iam_user_policy" "deployment" {
    name = "deployment"
    user = "${aws_iam_user.deployment.name}"
    policy = "${file(\"policies/deployment_policy.json\")}"
}
resource "aws_iam_access_key" "deployment" {
    user = "${aws_iam_user.deployment.name}"
}
