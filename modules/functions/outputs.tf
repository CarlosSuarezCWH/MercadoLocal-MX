output "lambda_arn" {
  value = aws_lambda_function.image_processor.arn
}

output "lambda_name" {
  value = aws_lambda_function.image_processor.function_name
}
