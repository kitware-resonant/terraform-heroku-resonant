data "aws_region" "current" {}

output "host" {
  # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-connect.html
  # SES is only available in limited regions, but provisioning should fail for other regions
  value       = "email-smtp.${data.aws_region.current.region}.amazonaws.com"
  description = "The hostname for the outgoing SMTP server."
}

output "port" {
  value       = 587
  description = "The port for the outgoing SMTP server."
}

output "username" {
  value       = aws_iam_access_key.smtp.id
  description = "The username for the outgoing SMTP server."
}

output "password" {
  value       = aws_iam_access_key.smtp.ses_smtp_password_v4
  sensitive   = true
  description = "The password for the outgoing SMTP server."
}

output "failures_topic_arn" {
  value       = aws_sns_topic.smtp_sns.arn
  description = "The SNS topic ARN for bounce, complaint, and reject notifications."
}
