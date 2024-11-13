output "authorizer" {
  description = "authorizer id if exist"
  value       = data.aws_api_gateway_authorizer.standard.id
}
