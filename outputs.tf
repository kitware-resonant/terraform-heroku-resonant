output "fqdn" {
  value       = aws_route53_record.heroku.fqdn
  description = "The fully-qualified domain name of the Heroku app."
}

output "heroku_app_id" {
  value       = module.heroku.app_id
  description = "The ID of the Heroku app."
}

output "heroku_iam_user_id" {
  value       = aws_iam_user.heroku_user.id
  description = "The ID of the IAM user for Heroku."
}

output "all_django_vars" {
  value       = module.heroku.all_config_vars
  description = "All Django environment variables, as they are effectively set."
  sensitive   = true
}

output "storage_bucket_name" {
  value       = module.storage.bucket_name
  description = "The storage S3 bucket name."
}

output "ec2_worker_hostnames" {
  value       = var.ec2_worker_instance_quantity > 0 ? aws_route53_record.ec2_worker[*].fqdn : []
  description = "The public hostnames of the EC2 workers."
}

output "ec2_worker_iam_role_id" {
  value       = var.ec2_worker_instance_quantity > 0 ? module.ec2_worker[0].iam_role_id : null
  description = "The ID of the instance profile IAM role for the EC2 workers."
}

output "smtp_failures_topic_arn" {
  value       = module.smtp.failures_topic_arn
  description = "The SNS topic ARN for SMTP bounce, complaint, and reject notifications."
}
