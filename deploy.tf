data "aws_api_gateway_rest_api" "primary" {
  name = var.api_gateway["api_id"]
}

resource "aws_api_gateway_resource" "resource" {
  for_each    = var.api_gateway["resources"]
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  parent_id   = data.aws_api_gateway_rest_api.primary.root_resource_id
  path_part   = each.key
}
resource "aws_api_gateway_method" "resource" {
  for_each             = var.api_gateway["resources"]
  rest_api_id          = data.aws_api_gateway_rest_api.primary.id
  resource_id          = aws_api_gateway_resource.resource[each.key].id
  http_method          = var.api_gateway["resources"][each.key]["http_method"]
  authorization        = var.api_gateway["resources"][each.key]["authorization"]
  authorizer_id        = var.api_gateway["authorizer"] == "cognito" || var.api_gateway["authorizer"] == "lambda" ? data.aws_api_gateway_authorizer.standard.id : null
  authorization_scopes = var.api_gateway["authorizer"] == "cognito" ? var.api_gateway["authorization_scopes"] : null
}
data "aws_api_gateway_authorizer" "standard" {
  rest_api_id   = data.aws_api_gateway_rest_api.primary.id
  authorizer_id = data.aws_api_gateway_authorizers.standard.ids[0]
}
data "aws_api_gateway_authorizers" "standard" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
}
resource "aws_api_gateway_usage_plan" "default" {
  name = data.aws_api_gateway_rest_api.primary.name

  throttle_settings {
    burst_limit = var.api_gateway["throttle"]["global"]["burst"]
    rate_limit  = var.api_gateway["throttle"]["global"]["rate"]
  }
  api_stages {
    api_id = data.aws_api_gateway_rest_api.primary.id
    stage  = var.api_gateway["stage"]
    dynamic "throttle" {
      for_each = var.api_gateway["resources"]
      content {
        path        = "/${aws_api_gateway_resource.resource[throttle.key].path_part}/${aws_api_gateway_method.resource[throttle.key].http_method}"
        burst_limit = var.api_gateway["resources"][throttle.key]["throttle"]["burst"]
        rate_limit  = var.api_gateway["resources"][throttle.key]["throttle"]["rate"]

      }
    }
  }
}

resource "aws_api_gateway_integration" "resource" {
  for_each                = var.api_gateway["resources"]
  http_method             = aws_api_gateway_method.resource[each.key].http_method
  resource_id             = aws_api_gateway_resource.resource[each.key].id
  rest_api_id             = data.aws_api_gateway_rest_api.primary.id
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = var.api_gateway["vpc_link_id"]
  integration_http_method = aws_api_gateway_method.resource[each.key].http_method
  uri                     = "${var.api_gateway["gateway_integration_uri"]}/${var.api_gateway["stage"]}/${aws_api_gateway_resource.resource[each.key].path_part}"
}
resource "aws_api_gateway_method_response" "resource" {
  for_each        = var.api_gateway["resources"]
  rest_api_id     = data.aws_api_gateway_rest_api.primary.id
  resource_id     = aws_api_gateway_resource.resource[each.key].id
  http_method     = aws_api_gateway_method.resource[each.key].http_method
  status_code     = var.api_gateway["resources"][each.key]["status_code"]
  response_models = { "application/json" : "Empty" }
}
resource "aws_api_gateway_integration_response" "resource" {
  for_each    = var.api_gateway["resources"]
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  resource_id = aws_api_gateway_resource.resource[each.key].id
  http_method = aws_api_gateway_method.resource[each.key].http_method
  status_code = aws_api_gateway_method_response.resource[each.key].status_code
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
      # aws_api_gateway_integration.probe.id,
      # aws_api_gateway_resource.probe.id,
      # aws_api_gateway_method.probe.id,
      aws_api_gateway_resource.resource,
      #  needed to avoid Provider produced inconsistent final plan (not true)
      # aws_api_gateway_method.resource,
      aws_api_gateway_integration.resource,
      aws_api_gateway_method_response.resource,
      # maybe is not needed
      aws_api_gateway_integration_response.resource
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
  access_log_settings {
    destination_arn = var.api_gateway["access_log_settings_destination_arn"]
    format          = var.api_gateway["access_log_settings_format"]
  }
}
#added
resource "aws_api_gateway_method_settings" "default" {
  rest_api_id = data.aws_api_gateway_rest_api.primary.id
  stage_name  = var.api_gateway["stage"]
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
  depends_on = [aws_api_gateway_usage_plan.default]
}
