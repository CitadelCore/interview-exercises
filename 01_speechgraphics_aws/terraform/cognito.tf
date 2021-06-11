resource "aws_cognito_user_pool" "default" {
    name = local.instance_name

    username_attributes = ["email"]

    schema {
        name = "email"
        attribute_data_type = "String"
        required = true
    }

    lifecycle {
        ignore_changes = all
    }
}

resource "aws_cognito_resource_server" "default" {
    user_pool_id = aws_cognito_user_pool.default.id
    name = "${local.instance_name}-scopes"

    identifier = "https://fileupload.example.com"

    scope {
        scope_name = "read"
        scope_description = "Read"
    }

    scope {
        scope_name = "write"
        scope_description = "Write"
    }

    scope {
        scope_name = "manage"
        scope_description = "Manage"
    }
}

resource "aws_cognito_user_pool_client" "default" {
    user_pool_id = aws_cognito_user_pool.default.id
    name = "${local.instance_name}-primary-client"

    generate_secret = false
    explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
    supported_identity_providers = ["COGNITO"]

    depends_on = [aws_cognito_resource_server.default]
}
