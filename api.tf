resource "aws_apigatewayv2_api" "weather_app_api" {
  name          = "weather-app-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "weather_app_stage" {
  api_id = aws_apigatewayv2_api.weather_app_api.id
  name   = "$default"
}

resource "aws_ssm_parameter" "api_id" {
  name  = "/${local.name}/http-api-id"
  type  = "String"
  value = aws_apigatewayv2_api.weather_app_api.id
}
