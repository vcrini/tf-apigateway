## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_authorizer.standard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_authorizer) | resource |
| [aws_api_gateway_deployment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.commesse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.probe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.commesse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.probe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.response_200](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.commesse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_resource.probe](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_stage.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_usage_plan.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_usage_plan) | resource |
| [aws_api_gateway_rest_api.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/api_gateway_rest_api) | data source |
| [aws_cognito_user_pools.standard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cognito_user_pools) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_id"></a> [api\_id](#input\_api\_id) | id for the reply's created api | `string` | n/a | yes |
| <a name="input_cognito_name"></a> [cognito\_name](#input\_cognito\_name) | name of cognito authorizer | `string` | n/a | yes |
| <a name="input_cognito_user_pool_name"></a> [cognito\_user\_pool\_name](#input\_cognito\_user\_pool\_name) | name of cognito user pool | `string` | n/a | yes |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | test or prod environment | `string` | n/a | yes |
| <a name="input_lb_name"></a> [lb\_name](#input\_lb\_name) | balancer name | `string` | n/a | yes |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | listener arn | `string` | `""` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | name of the repository inferred by directory name | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | name for stage | `string` | `"api"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tag to be added | `map(any)` | <pre>{<br>  "Project": "FactoryDataHub"<br>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | id representing AWS Virtual Private Cloud | `string` | n/a | yes |
| <a name="input_vpc_link_id"></a> [vpc\_link\_id](#input\_vpc\_link\_id) | virtual private cloud descriptor | `string` | n/a | yes |

## Outputs

No outputs.
