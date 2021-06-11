# Task policy, used for execution of the actual task containers
resource "aws_iam_role" "ecs_task_role" {
    name = "${local.instance_name}-ecs-task-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow"
    }]
}
EOF
}

resource "aws_iam_policy" "ecs_task_policy" {
    name = "${local.instance_name}-ecs-task-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "${aws_s3_bucket.uploads.arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:UpdateTimeToLive",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
            "Resource": "${aws_dynamodb_table.uploads.arn}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:AdminGetUser",
                "cognito-idp:AdminInitiateAuth"
            ],
            "Resource": "${aws_cognito_user_pool.default.arn}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
    role = aws_iam_role.ecs_task_role.name
    policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# Host role, used to authorise the EC2 host services
resource "aws_iam_role" "ecs_host_role" {
    name = "${local.instance_name}-ecs-host-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": [
                "ecs.amazonaws.com",
                "ec2.amazonaws.com"
            ]
        },
        "Effect": "Allow"
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_host_policy_attachment" {
    role = aws_iam_role.ecs_host_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs" {
    name = "${local.instance_name}-ecs-profile"
    role = aws_iam_role.ecs_host_role.name
    path = "/"
}

resource "aws_iam_role" "ecs_service_role" {
    name = "${local.instance_name}-ecs-service-role"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": [
                "ecs.amazonaws.com",
                "ec2.amazonaws.com"
            ]
        },
        "Effect": "Allow"
    }]
}
EOF
}

resource "aws_iam_policy" "ecs_service_policy" {
    name = "${local.instance_name}-ecs-service-policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:AuthorizeSecurityGroupIngress",
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_service_policy_attachment" {
    role = aws_iam_role.ecs_service_role.name
    policy_arn = aws_iam_policy.ecs_service_policy.arn
}
