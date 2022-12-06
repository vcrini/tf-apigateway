data "aws_api_gateway_rest_api" "primary" {
  name = var.api_gateway["api_id"]
}

resource "aws_api_gateway_resource" "commesse" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  parent_id   = data.aws_api_gateway_rest_api.primary.root_resource_id
  path_part   = "commesse"
}
resource "aws_api_gateway_resource" "probe" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  parent_id   = data.aws_api_gateway_rest_api.primary.root_resource_id
  path_part   = "probe"
}
#GET
resource "aws_api_gateway_method" "commesse" {
  rest_api_id          = data.aws_api_gateway_rest_api.primary.id
  resource_id          = aws_api_gateway_resource.commesse.id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.standard.id
  authorization_scopes = ["openid"]
}
resource "aws_api_gateway_method" "probe" {
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  resource_id   = aws_api_gateway_resource.probe.id
  http_method   = "GET"
  authorization = "NONE"
}
data "aws_cognito_user_pools" "standard" {
  name = var.api_gateway["cognito_user_pool_name"]
}
resource "aws_api_gateway_authorizer" "standard" {
  name          = var.api_gateway["cognito_name"]
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  provider_arns = data.aws_cognito_user_pools.standard.arns
}
resource "aws_api_gateway_usage_plan" "default" {
  name         = "default"
  description  = "used for commesse and probe"
  product_code = "MYCODE"

  #quota_settings {
  #  limit  = 20
  #  offset = 2
  #  period = "WEEK"
  #}

  throttle_settings {
    burst_limit = var.api_gateway["throttle"]["global"]["burst"]
    rate_limit  = var.api_gateway["throttle"]["global"]["rate"]
  }
  api_stages {
    api_id = data.aws_api_gateway_rest_api.primary.id
    stage  = var.api_gateway["stage"]
    throttle {
      # commesse
      path        = "/${aws_api_gateway_resource.commesse.path_part}/${aws_api_gateway_method.commesse.http_method}"
      burst_limit = var.api_gateway["throttle"]["commesse"]["burst"]
      rate_limit  = var.api_gateway["throttle"]["commesse"]["rate"]
    }
    throttle {
      # probe
      path        = "/${aws_api_gateway_resource.probe.path_part}/${aws_api_gateway_method.probe.http_method}"
      burst_limit = var.api_gateway["throttle"]["probe"]["burst"]
      rate_limit  = var.api_gateway["throttle"]["probe"]["rate"]
    }
  }
}

resource "aws_api_gateway_integration" "commesse" {
  http_method             = aws_api_gateway_method.commesse.http_method
  resource_id             = aws_api_gateway_resource.commesse.id
  rest_api_id             = data.aws_api_gateway_rest_api.primary.id
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = var.api_gateway["vpc_link_id"]
  integration_http_method = "GET"
  uri                     = "${var.api_gateway["gateway_integration_uri"]}/${var.api_gateway["stage"]}/${aws_api_gateway_resource.commesse.path_part}"
}
resource "aws_api_gateway_integration" "probe" {
  http_method             = aws_api_gateway_method.probe.http_method
  resource_id             = aws_api_gateway_resource.probe.id
  rest_api_id             = data.aws_api_gateway_rest_api.primary.id
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = var.api_gateway["vpc_link_id"]
  integration_http_method = "GET"
  uri                     = "${var.api_gateway["gateway_integration_uri"]}/${var.api_gateway["stage"]}/${aws_api_gateway_resource.probe.path_part}"
}
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id     = data.aws_api_gateway_rest_api.primary.id
  resource_id     = aws_api_gateway_resource.commesse.id
  http_method     = aws_api_gateway_method.commesse.http_method
  status_code     = "200"
  response_models = { "application/json" : "Empty" }
}
resource "aws_api_gateway_integration_response" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  resource_id = aws_api_gateway_resource.commesse.id
  http_method = aws_api_gateway_method.commesse.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}
resource "aws_api_gateway_deployment" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.commesse.id,
      aws_api_gateway_integration.probe.id,
      aws_api_gateway_resource.commesse.id,
      aws_api_gateway_method.commesse.id,
      aws_api_gateway_resource.probe.id,
      aws_api_gateway_method.probe.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  stage_name    = var.api_gateway["stage"]
}
