[
    {
        "name": "filestore",
        "image": "${account_id}.dkr.ecr.${region}.amazonaws.com/${instance}-app:latest",
        "essential": true,
        "cpu": 10,
        "memory": 512,
        "links": [],
        "portMappings": [{
            "containerPort": 8000,
            "hostPort": 0,
            "protocol": "tcp"
        }],
        "command": ["bash", "run.sh"],
        "environment": [{
            "name": "AWS_DEFAULT_REGION",
            "value": "${region}"
        }],
        "mountPoints": [
            {
                "containerPath": "/app/persist",
                "sourceVolume": "persist"
            }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/filestore/${env}",
                "awslogs-region": "${region}"
            }
        }
    },
    {
        "name": "nginx",
        "image": "${account_id}.dkr.ecr.${region}.amazonaws.com/${instance}-nginx:latest",
        "essential": true,
        "cpu": 10,
        "memory": 128,
        "links": ["filestore"],
        "portMappings": [{
            "containerPort": 80,
            "hostPort": 0,
            "protocol": "tcp"
        }],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/filestore/${env}",
                "awslogs-region": "${region}"
            }
        }
    }
]