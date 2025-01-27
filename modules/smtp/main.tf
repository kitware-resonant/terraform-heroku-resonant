resource "aws_ses_domain_identity" "smtp" {
  # "www." will also be included as a subdomain,
  # but specifying it is not allowed:
  # https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html
  domain = trimprefix("www.", var.fqdn)
}

resource "aws_route53_record" "smtp_verification" {
  zone_id = var.route53_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.smtp.domain}"
  type    = "TXT"
  ttl     = "1800"
  records = [aws_ses_domain_identity.smtp.verification_token]
}

resource "aws_ses_domain_identity_verification" "smtp_verification" {
  domain     = aws_ses_domain_identity.smtp.id
  depends_on = [aws_route53_record.smtp_verification]
}

resource "aws_ses_domain_dkim" "smtp" {
  domain = aws_ses_domain_identity.smtp.domain
}

resource "aws_route53_record" "smtp_dkim" {
  count   = 3
  zone_id = var.route53_zone_id
  name    = "${element(aws_ses_domain_dkim.smtp.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_dkim.smtp.domain}"
  type    = "CNAME"
  ttl     = "1800"
  records = ["${element(aws_ses_domain_dkim.smtp.dkim_tokens, count.index)}.dkim.amazonses.com"]
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
    resources = [aws_ses_domain_identity.smtp.arn]
    actions   = ["ses:SendRawEmail"]
  }
}
