
variable "api_id" {
  description = "id for the reply's created api"
  type        = string
}
variable "cognito_user_pool_name" {
  description = "name of cognito user pool"
  type        = string
}
variable "cognito_name" {
  description = "name of cognito authorizer"
  type        = string
}
variable "deploy_environment" {
  description = "test or prod environment"
  type        = string
}
variable "lb_name" {
  description = "balancer name"
  type        = string
}

variable "listener_arn" {
  default     = ""
  description = "listener arn"
  type        = string
}
variable "repository_name" {
  description = "name of the repository inferred by directory name"
  type        = string
}
#variable "ssl_certificate_arn" {
#  type        = string
#  description = "ARN of the default SSL server certificate"
#}
variable "stage" {
  default     = "api"
  description = "name for stage"
  type        = string
}
variable "tags" {
  default = {
    Project = "FactoryDataHub"
  }
  description = "tag to be added"
  type        = map(any)
}
variable "vpc_id" {
  description = "id representing AWS Virtual Private Cloud"
  type        = string
}

variable "vpc_link_id" {
  type        = string
  description = "virtual private cloud descriptor"
}

