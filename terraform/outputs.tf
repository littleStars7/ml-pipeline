# -----------------------
# Outputs
# -----------------------

output "sagemaker_role_arn" {
  value = aws_iam_role.sagemaker_role.arn
  description = "ARN of the SageMaker IAM role"
}

output "processed_data_bucket" {
  value = aws_s3_bucket.processed.bucket
  description = "Name of the processed data bucket"
}

output "models_bucket" {
  value = aws_s3_bucket.models.bucket
  description = "Name of the models bucket"
}