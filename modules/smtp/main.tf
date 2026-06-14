locals {
  # "www." will also be included as a subdomain, but specifying it is not allowed:
  # https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html
  fqdn = trimprefix(var.fqdn, "www.")
}

resource "aws_sesv2_email_identity" "smtp" {
  email_identity = local.fqdn
}

resource "aws_route53_record" "smtp_dkim" {
  count   = 3
  zone_id = var.route53_zone_id
  # "name" and "records" values are documented:
  # https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-dkim-easy-managing.html
  name    = "${one(aws_sesv2_email_identity.smtp.dkim_signing_attributes).tokens[count.index]}._domainkey.${local.fqdn}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${one(aws_sesv2_email_identity.smtp.dkim_signing_attributes).tokens[count.index]}.dkim.amazonses.com"]
}

# TODO: setup bounce notification to SNS
# https://www.terraform.io/docs/providers/aws/r/ses_identity_notification_topic.html

resource "aws_iam_user" "smtp" {
  name = "${var.project_slug}-smtp"
}

# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/smtp-credentials.html
resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

resource "aws_iam_user_policy" "smtp" {
  user   = aws_iam_user.smtp.id
  name   = "${var.project_slug}-smtp"
  policy = data.aws_iam_policy_document.smtp.json
}

data "aws_iam_policy_document" "smtp" {
  statement {
    # https://docs.aws.amazon.com/ses/latest/DeveloperGuide/control-user-access.html
    resources = [aws_sesv2_email_identity.smtp.arn]
    actions   = ["ses:SendRawEmail"]
  }
}
