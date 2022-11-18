#data "aws_lb" "nlb" {
#  name  = var.nlb_name
#}
#resource "aws_alb_listener" "nlb_listener" {
#  for_each          = var.listener
#  load_balancer_arn = data.aws_lb.nlb[0].arn
#  port              = each.value["balancer_port"]
#  protocol          = "TCP"
#  tags              = var.tags
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.nlb_targets[local.redirect && each.key == "80" ? "redirect" : each.value["default_action"]].arn
#  }
#}
#
#
#resource "aws_lb_target_group" "nlb_targets" {
#  for_each             = var.target_group
#  deregistration_delay = var.deregistration_delay
#  lifecycle {
#    create_before_destroy = true
#    ignore_changes        = [name]
#  }
#  name        = substr(format("%s-%s", "${var.prefix}-${var.deploy_environment}-${index(keys(var.target_group), each.key)}-ntg", replace(uuid(), "-", "")), 0, 32)
#  port        = each.value["destination_port"]
#  protocol    = each.value["destination_protocol"]
#  target_type = "ip"
#  tags        = var.tags
#  vpc_id      = var.vpc_id
#  stickiness {
#    type    = "lb_cookie"
#    enabled = each.value["stickiness"]
#  }
#  dynamic "health_check" {
#    for_each = lookup(each.value, "health_path", null) != null ? [1] : []
#    content {
#      matcher             = each.value["health_http_code"]
#      protocol            = each.value["health_protocol"]
#      path                = each.value["health_path"]
#      timeout             = lookup(each.value, "timeout", null)
#      interval            = lookup(each.value, "interval", null)
#      healthy_threshold   = lookup(each.value, "healthy_threshold", null)
#      unhealthy_threshold = lookup(each.value, "unhealthy_threshold", null)
#    }
#  }
#}
#
#
#resource "aws_alb_listener_rule" "route_path" {
#  for_each     = var.target_group
#  listener_arn = aws_alb_listener.alb_listener[each.value["listener"]].arn
#  tags         = var.tags
#  action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.lb_targets[each.key].arn
#  }
#  condition {
#    host_header {
#      values = [
#        lookup(each.value, "cname", "not present") == "not present" ? var.default_cname : each.value["cname"]
#      ]
#    }
#  }
#  lifecycle {
#    ignore_changes = [priority]
#  }
#}
#





#!#resource "aws_apigatewayv2_stage" "primary" {
#!#  api_id = data.aws_apigatewayv2_api.primary.id
#!#  #name   = var.deploy_environment
#!#  name        = "$default"
#!#  auto_deploy = true
#!#  #name   = "fdh-probe"
#!#  default_route_settings {
#!#    #route_key              = "ANY /"
#!#    throttling_burst_limit = 1
#!#    throttling_rate_limit  = 1
#!#    #detailed_metrics_enabled = true
#!#  }
#!#  #route_settings {
#!#  #  route_key              = "ANY /{proxy+}"
#!#  #  throttling_burst_limit = 1
#!#  #  throttling_rate_limit  = 1
#!#  #}
#!#  #tags = var.tags
#!#}
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
#1#data "aws_apigatewayv2_api" "primary" {
#1#  api_id = var.api_id
#1#}
#resource "aws_api_gateway_rest_api" "primary" {
#  body= file("${path.module}/openapi.json")
#  name = var.api_id
#}
data "aws_api_gateway_rest_api" "primary" {
  name = var.api_id
}

#2#resource "aws_api_gateway_resource" "api" {
#2#  rest_api_id = data.aws_api_gateway_rest_api.primary.id
#2#  parent_id   = data.aws_api_gateway_rest_api.primary.root_resource_id
#2#  path_part   = "api"
#2#}
data "aws_api_gateway_resource" "api" {
  path        = "/api"
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
}
#2#resource "aws_api_gateway_resource" "commesse-list" {
#2#  rest_api_id = data.aws_api_gateway_rest_api.primary.id
#2#  parent_id   = data.aws_api_gateway_resource.api.id
#2#  path_part   = "commesse-list"
#2#}
resource "aws_api_gateway_resource" "commesse_list2" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  parent_id   = data.aws_api_gateway_resource.api.id
  path_part   = "commesse-list-terraform"
}
#GET
resource "aws_api_gateway_method" "commesse_list2" {
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  resource_id   = aws_api_gateway_resource.commesse_list2.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.standard.id
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
#next to signal
#Error: error reading Cognito User Pools: AccessDeniedException: User: arn:aws:sts::796341525871:assumed-role/bitgdi-test-admin/aws-go-sdk-1668157732632494000 is not authorized to perform: cognito-idp:ListUserPools on resource: * because no identity-based policy allows the cognito-idp:ListUserPools action

#!#resource "aws_apigatewayv2_route" "primary" {
#!#  #api_id    = data.aws_apigatewayv2_api.primary.id
#!#  api_id    = data.aws_apigateway_rest_api.primary.id
#!#  route_key = "ANY /{proxy+}"
#!#
#!#  target = "integrations/${aws_apigatewayv2_integration.primary.id}"
#!#}
#resource "aws_apigatewayv2_route" "secondary" {
#  api_id    = data.aws_apigatewayv2_api.primary.id
#  route_key = "ANY /fdh/api/probe2"
#
#  target = "integrations/${aws_apigatewayv2_integration.primary.id}"
#}
#!#resource "aws_apigatewayv2_integration" "primary" {
#!#  api_id           = data.aws_apigatewayv2_api.primary.id
#!#  description      = "using the load balancer"
#!#  integration_type = "HTTP_PROXY"
#!#  #integration_uri  = var.listener_arn
#!#
#!#  integration_method = "ANY"
#!#  connection_type    = "VPC_LINK"
#!#  connection_id      = var.vpc_link_id
#!#
#!#}
#data "aws_apigatewayv2_domain_name" "primary" {
#  domain_name = "gdh-atlas-kubix-test.datahub.gucci"
#}
#data "aws_api_gateway_domain_name" "primary" {
#  domain_name = "gdh-atlas-kubix-test.datahub.gucci"
#}
#resource "aws_apigatewayv2_api_mapping" "primary" {
#  api_id      = data.aws_apigatewayv2_api.primary.id
#  domain_name = data.aws_api_gateway_domain_name.primary.id
#  #domain_name = data.aws_apigatewayv2_domain_name.primary.id
#  stage = aws_apigatewayv2_stage.primary.id
#  #api_mapping_key= "fdh/api/probe"
#}
#resource "aws_apigatewayv2_api_mapping" "secondary" {
#  api_id      = data.aws_apigatewayv2_api.primary.id
#  domain_name = data.aws_api_gateway_domain_name.primary.id
#  #domain_name = data.aws_apigatewayv2_domain_name.primary.id
#  stage       = aws_apigatewayv2_stage.primary.id
#}
resource "aws_api_gateway_usage_plan" "example" {
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }

}

#resource "aws_api_gateway_deployment" "example" {
#  rest_api_id = data.aws_api_gateway_rest_api.primary.id
#
#  triggers = {
#    redeployment = sha1(jsonencode(data.aws_api_gateway_rest_api.primary.id))
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
#resource "aws_api_gateway_stage" "example" {
#  deployment_id = aws_api_gateway_deployment.example.id
#  rest_api_id = data.aws_api_gateway_rest_api.primary.id
#  stage_name    = "example"
#}
#
#resource "aws_api_gateway_method_settings" "example" {
#  rest_api_id = data.aws_api_gateway_rest_api.primary.id
#  stage_name  = aws_api_gateway_stage.example.stage_name
#  method_path = "*/*"
#
#  settings {
#    metrics_enabled = true
#    logging_level   = "INFO"
#  }
#}

resource "aws_api_gateway_integration" "example" {
  http_method = aws_api_gateway_method.commesse_list2.http_method
  resource_id = aws_api_gateway_resource.commesse_list2.id
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "example" {
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
      aws_api_gateway_integration.example.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

