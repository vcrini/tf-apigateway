## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_id | id for the reply's created api | `string` | n/a | yes |
| deploy\_environment | test or prod environment | `string` | n/a | yes |
| lb\_name | balancer name | `string` | n/a | yes |
| listener\_arn | listener arn | `string` | n/a | yes |
| repository\_name | name of the repository inferred by directory name | `string` | n/a | yes |
| tags | tag to be added | `map(any)` | <pre>{<br>  "Project": "FactoryDataHub"<br>}</pre> | no |
| vpc\_id | id representing AWS Virtual Private Cloud | `string` | n/a | yes |
| vpc\_link\_id | virtual private cloud descriptor | `string` | n/a | yes |

## Outputs

No output.

