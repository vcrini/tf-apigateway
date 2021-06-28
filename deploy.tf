resource "aws_apigatewayv2_stage" "primary" {
  api_id = aws_apigatewayv2_api.primary.id
  name   = var.deploy_environment
  route_settings {
    route_key              = "ANY /fdh/api/probe"
    throttling_burst_limit = 1
    throttling_rate_limit  = 1
  }
}
resource "aws_apigatewayv2_api" "primary" {
  name          = var.repository_name
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_domain_name" "primary" {
  domain_name = "gdh-atlas-kubix-test.datahub.gucci"
  domain_name_configuration {
    certificate_arn = var.ssl_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

}

# primary DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "primary" {
  name    = aws_apigatewayv2_domain_name.primary.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_apigatewayv2_domain_name.primary.domain_name
    zone_id                = aws_apigatewayv2_domain_name.primary.domain_name
  }
}
resource "aws_apigatewayv2_api_mapping" "primary" {
  api_id      = aws_apigatewayv2_api.primary.id
  domain_name = aws_apigatewayv2_domain_name.primary.id
  stage       = aws_apigatewayv2_stage.primary.id
}

resource "aws_apigatewayv2_route" "primary" {
  api_id    = aws_apigatewayv2_api.primary.id
  route_key = "ANY /fdh/api/probe"

  target = "integrations/${aws_apigatewayv2_integration.primary.id}"
}
resource "aws_apigatewayv2_integration" "primary" {
  api_id           = aws_apigatewayv2_api.primary.id
  description      = "using the load balancer"
  integration_type = "HTTP_PROXY"
  integration_uri  = var.listener_arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  #connection_id      = aws_apigatewayv2_vpc_link.primary.id <<== ask
  connection_id = 23984798

}

