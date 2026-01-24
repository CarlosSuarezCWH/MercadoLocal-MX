resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "media" {
  bucket = lower("${var.project_name}-media-${random_id.bucket_suffix.hex}")

  tags = {
    Name = "MediaBucket"
  }
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Zip the lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/image_processor.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "image_processor" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-Image-Processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "image_processor.lambda_handler"
  runtime       = "python3.12"
  timeout       = 10

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# S3 Trigger
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.media.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.media.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg" # Example filter
  }
  
  depends_on = [aws_lambda_permission.allow_bucket]
}
