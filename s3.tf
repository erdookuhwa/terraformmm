data "archive_file" "api_code_archive" {
  type        = "zip"
  source_file = "./lambda_function.py"
  output_path = "bootstrap.zip"
}

resource "aws_s3_bucket" "api_bucket" {
  bucket        = "erdoo-api-bucket-archives"
  force_destroy = true
}

resource "aws_s3_bucket_object" "api_code_archive" {
  bucket = aws_s3_bucket.api_bucket.id
  key    = "bootstrap.zip"
  source = data.archive_file.api_code_archive.output_path
  etag   = filemd5(data.archive_file.api_code_archive.output_path)

  lifecycle {
    ignore_changes = [
      etag,
      version_id
    ]
  }
}

resource "aws_lambda_function" "api_lambda" {
  function_name    = "example-api"
  role             = aws_iam_role.api_lambda_role.arn
  s3_bucket        = aws_s3_bucket.api_bucket.id
  s3_key           = aws_s3_bucket_object.api_code_archive.key
  source_code_hash = data.archive_file.api_code_archive.output_base64sha256
  architectures    = ["arm64"]
  runtime          = "provided.al2"
  handler          = "bootstrap"
  memory_size      = 128
  publish          = true

  lifecycle {
    ignore_changes = [
      last_modified,
      source_code_hash,
      version,
      environment
    ]
  }
}

resource "aws_iam_role" "api_lambda_role" {
  name = "example-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}