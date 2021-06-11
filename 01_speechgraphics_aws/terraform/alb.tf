resource "aws_security_group" "alb" {
    name = "${local.instance_name}-alb"
    vpc_id = aws_vpc.default.id

    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

resource "aws_lb" "default" {
    name = "${local.instance_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    enable_deletion_protection = false
}

resource "aws_alb_target_group" "default" {
    name = "${local.instance_name}-target-group"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.default.id
    deregistration_delay = 0

    health_check {
        healthy_threshold = "3"
        interval = "30"
        protocol = "HTTP"
        matcher = "200"
        timeout = "3"
        path = "/"
        unhealthy_threshold = "2"
    }
}

resource "aws_alb_listener" "default" {
    load_balancer_arn = aws_lb.default.id
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_alb_target_group.default.arn
    }
}
