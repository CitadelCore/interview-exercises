resource "aws_dynamodb_table" "uploads" {
    name = "${local.instance_name}-uploads"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"

    attribute {
        name = "id"
        type = "S"
    }
}
