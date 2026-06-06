output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.bedrock.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.bedrock.name
}

output "region" {
  description = "AWS region"
  value       = "us-east-1"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.bedrock_vpc.id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = aws_s3_bucket.assets.id
}

output "developer_access_key_id" {
  description = "Developer IAM access key ID"
  value       = aws_iam_access_key.dev_keys.id
}

output "developer_secret_access_key" {
  description = "Developer IAM secret access key"
  value       = aws_iam_access_key.dev_keys.secret
  sensitive   = true
}

output "developer_console_password" {
  description = "Developer console login password"
  value       = aws_iam_user_login_profile.dev_login.password
  sensitive   = true
}
