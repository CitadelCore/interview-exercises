resource "aws_security_group" "ecs" {
    name = "${local.instance_name}-ecs"
    description = "Allow SSH and access from the ELB"
    vpc_id = aws_vpc.default.id

    ingress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        security_groups = [aws_security_group.alb.id]
    }

    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
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

resource "aws_ecr_repository" "app" {
    name = "${local.instance_name}-app"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "nginx" {
    name = "${local.instance_name}-nginx"
    image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "app" {
    repository = aws_ecr_repository.app.name
    policy = file("policy/lifecycle.json")
}

resource "aws_ecr_lifecycle_policy" "nginx" {
    repository = aws_ecr_repository.nginx.name
    policy = file("policy/lifecycle.json")
}

resource "aws_ecs_cluster" "default" {
    name = "${local.instance_name}-cluster"
}

resource "aws_launch_configuration" "default" {
    name = "${local.instance_name}-cluster"
    image_id = local.ecs_instance_ami
    instance_type = local.ecs_instance_type
    security_groups = [aws_security_group.ecs.id]
    iam_instance_profile = aws_iam_instance_profile.ecs.name
    key_name = aws_key_pair.default.key_name
    associate_public_ip_address = true

    # required for instance discovery by ECS
    user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER="${local.instance_name}-cluster" > /etc/ecs/ecs.config
EOF
}

data "template_file" "app" {
    template = file("templates/app.json.tpl")

    vars = {
        env = var.environment
        region = "eu-west-2"
        instance = local.instance_name
        account_id = data.aws_caller_identity.current.account_id
    }
}

resource "aws_ecs_task_definition" "default" {
    family = "${local.instance_name}-task"
    task_role_arn = aws_iam_role.ecs_task_role.arn
    container_definitions = data.template_file.app.rendered

    volume {
        name = "persist"
        host_path = "/app/persist/"
    }
}

resource "aws_ecs_service" "default" {
    name = "${local.instance_name}-service"
    cluster = aws_ecs_cluster.default.id
    task_definition = aws_ecs_task_definition.default.arn
    iam_role = aws_iam_role.ecs_service_role.arn
    desired_count = 1
    depends_on = [aws_alb_listener.default, aws_iam_policy.ecs_service_policy]

    load_balancer {
        target_group_arn = aws_alb_target_group.default.arn
        container_name = "nginx"
        container_port = "80"
    }
}
