resource "aws_cloudwatch_log_group" "default" {
    name = "/ecs/filestore/${var.environment}"
    retention_in_days = 30
}

resource "aws_cloudwatch_log_stream" "default" {
    name = "default"
    log_group_name = aws_cloudwatch_log_group.default.name
}
