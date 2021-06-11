resource "aws_autoscaling_group" "ecs" {
    name = "${local.instance_name}-auto-scaling"
    min_size = 1
    max_size = 4
    desired_capacity = 1
    health_check_type = "EC2"
    launch_configuration = aws_launch_configuration.default.name
    vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}
