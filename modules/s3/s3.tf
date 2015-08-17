# s3 bucket requires gloable unique bucket name, make sure set a prefix bucket 
# to make the bucket name unique

variable "bucket_prefix" {
    default = "mycluster"
}

# s3 bucket for cloudinit files
resource "aws_s3_bucket" "cloudinit" {
    bucket = "${var.bucket_prefix}-cloudinit"
    acl = "private"
    force_destroy = true
    tags {
        Name = "Cloudinit"
    }
}
# s3 bucket for application configuration,Shared by all cluster nodes
resource "aws_s3_bucket" "config" {
    bucket = "${var.bucket_prefix}-config"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Config"
    }
}

# s3 bucket for data backup
resource "aws_s3_bucket" "data" {
    bucket = "${var.bucket_prefix}-logs"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Logs"
    }
}

# s3 bucket for log data backup
resource "aws_s3_bucket" "logs" {
    bucket = "${var.bucket_prefix}-logs"
    force_destroy = true
    acl = "private"
    tags {
        Name = "Logs"
    }
}
