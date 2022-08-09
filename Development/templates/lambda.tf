# ####### Lambda boopos-pdf-dev ################

# # data "archive_file" "boopos-pdf-dev" {
# #   type = "zip"

# #   source_dir  = "${path.module}/hello-world"
# #   output_path = "${path.module}/hello-world.zip"
# # }

# resource "aws_s3_bucket" "boopos-pdf-dev" {
#     bucket          = "boopos-pdf-dev-${local.account_id}"
#     #force_destroy   = false
#     force_destroy   = true
# }

# resource "aws_s3_object" "boopos-pdf-dev" {
#   bucket = aws_s3_bucket.boopos-pdf-dev.id

#   key    = "hello-world.zip"
#   #source = data.archive_file.lambda_hello_world.output_path
# }


# resource "aws_lambda_function" "boopos-pdf-dev" {
#   function_name = "boopos-pdf-dev"

#   s3_bucket = aws_s3_bucket.boopos-pdf-dev.id
#   s3_key    = aws_s3_object.boopos-pdf-dev.key

#   runtime = "nodejs14.x"
#   handler = "hello.handler"

#   #source_code_hash = data.archive_file.boopos-pdf-dev.output_base64sha256

#   role = aws_iam_role.lambda_exec.arn
# }

# resource "aws_cloudwatch_log_group" "boopos-pdf-dev" {
#   name = "/aws/lambda/${aws_lambda_function.boopos-pdf-dev.function_name}"

#   retention_in_days = 30
# }

# resource "aws_iam_role" "lambda_exec" {
#   name = "serverless_lambda"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Sid    = ""
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
