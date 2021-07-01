resource "aws_apigatewayv2_stage" "primary" {
  api_id = data.aws_apigatewayv2_api.primary.id
  #name   = var.deploy_environment
  name        = "$default"
  auto_deploy = true
  #name   = "fdh-probe"
  default_route_settings {
    #route_key              = "ANY /"
    throttling_burst_limit = 1
    throttling_rate_limit  = 1
    #detailed_metrics_enabled = true
  }
  #route_settings {
  #  route_key              = "ANY /{proxy+}"
  #  throttling_burst_limit = 1
  #  throttling_rate_limit  = 1
  #}
  #tags = var.tags
}
#resource "aws_apigatewayv2_stage" "secondary" {
#  api_id = data.aws_apigatewayv2_api.primary.id
#  name   =  "fdh-root"
#  route_settings {
#    route_key              = "ANY /"
#    throttling_burst_limit = 1
#    throttling_rate_limit  = 1
#  }
#  #tags = var.tags
#}
data "aws_apigatewayv2_api" "primary" {
  api_id = var.api_id
}

resource "aws_apigatewayv2_route" "primary" {
  api_id    = data.aws_apigatewayv2_api.primary.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.primary.id}"
}
#resource "aws_apigatewayv2_route" "secondary" {
#  api_id    = data.aws_apigatewayv2_api.primary.id
#  route_key = "ANY /fdh/api/probe2"
#
#  target = "integrations/${aws_apigatewayv2_integration.primary.id}"
#}
resource "aws_apigatewayv2_integration" "primary" {
  api_id           = data.aws_apigatewayv2_api.primary.id
  description      = "using the load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = var.listener_arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = var.vpc_link_id

}
#data "aws_apigatewayv2_domain_name" "primary" {
#  domain_name = "gdh-atlas-kubix-test.datahub.gucci"
#}
data "aws_api_gateway_domain_name" "primary" {
  domain_name = "gdh-atlas-kubix-test.datahub.gucci"
}
resource "aws_apigatewayv2_api_mapping" "primary" {
  api_id      = data.aws_apigatewayv2_api.primary.id
  domain_name = data.aws_api_gateway_domain_name.primary.id
  #domain_name = data.aws_apigatewayv2_domain_name.primary.id
  stage = aws_apigatewayv2_stage.primary.id
  #api_mapping_key= "fdh/api/probe"
}
#resource "aws_apigatewayv2_api_mapping" "secondary" {
#  api_id      = data.aws_apigatewayv2_api.primary.id
#  domain_name = data.aws_api_gateway_domain_name.primary.id
#  #domain_name = data.aws_apigatewayv2_domain_name.primary.id
#  stage       = aws_apigatewayv2_stage.primary.id
#}

