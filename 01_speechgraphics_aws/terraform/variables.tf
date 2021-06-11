data "aws_caller_identity" "current" {}

variable "environment" {
    description = "Environment type (dev, staging, prod)"
    default = "dev"
}

locals {
    instance_name = "filestore-${var.environment}"
    availability_zones = ["eu-west-2a", "eu-west-2b"]

    ecs_instance_ami = "ami-0cd4858f2b923aa6b"
    ecs_instance_type = "t2.micro"
}
