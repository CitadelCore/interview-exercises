resource "aws_s3_bucket" "uploads" {
    bucket = "${local.instance_name}-uploads"
    acl = "private"
}
