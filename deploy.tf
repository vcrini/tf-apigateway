data "aws_api_gateway_rest_api" "primary" {
  name = var.api_id
}

resource "aws_api_gateway_resource" "commesse_list2" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  parent_id   = data.aws_api_gateway_rest_api.primary.root_resource_id
  path_part   = "commesse"
}
#GET
resource "aws_api_gateway_method" "commesse_list2" {
  rest_api_id          = data.aws_api_gateway_rest_api.primary.id
  resource_id          = aws_api_gateway_resource.commesse_list2.id
  http_method          = "GET"
  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.standard.id
  authorization_scopes = ["openid"]
  #request_parameters = {
  #  "method.request.path.commesse-list-terraform" = true
  #}
}
#cognito
data "aws_cognito_user_pools" "standard" {
  name = "bitgdi-test-cognito"
}
resource "aws_api_gateway_authorizer" "standard" {
  name          = "bitgdi-test-authz-test"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  provider_arns = data.aws_cognito_user_pools.standard.arns
}
resource "aws_api_gateway_usage_plan" "default" {
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  #quota_settings {
  #  limit  = 20
  #  offset = 2
  #  period = "WEEK"
  #}

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
  api_stages {
    api_id = data.aws_api_gateway_rest_api.primary.id
    stage  = var.stage
    throttle {
      # fix down with dynamic string
      path        = "/commesse/GET"
      burst_limit = "3"
      rate_limit  = "2"
    }
  }

}

resource "aws_api_gateway_integration" "default" {
  http_method             = aws_api_gateway_method.commesse_list2.http_method
  resource_id             = aws_api_gateway_resource.commesse_list2.id
  rest_api_id             = data.aws_api_gateway_rest_api.primary.id
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  integration_http_method = "GET"
  uri                     = "http://bitgdi-test-sandboxecs-inlb-c2ede020b1256ea8.elb.eu-west-1.amazonaws.com/${var.stage}/${aws_api_gateway_resource.commesse_list2.path_part}"
}
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id     = data.aws_api_gateway_rest_api.primary.id
  resource_id     = aws_api_gateway_resource.commesse_list2.id
  http_method     = aws_api_gateway_method.commesse_list2.http_method
  status_code     = "200"
  response_models = { "application/json" : "Empty" }
}
resource "aws_api_gateway_integration_response" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  resource_id = aws_api_gateway_resource.commesse_list2.id
  http_method = aws_api_gateway_method.commesse_list2.http_method
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
      aws_api_gateway_integration.default.id,
      aws_api_gateway_resource.commesse_list2.id,
      aws_api_gateway_method.commesse_list2.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.default.id
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  stage_name    = var.stage
}
