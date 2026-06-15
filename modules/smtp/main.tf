locals {
  # "www." will also be included as a subdomain, but specifying it is not allowed:
  # https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html
  fqdn = trimprefix(var.fqdn, "www.")
}

resource "aws_sesv2_configuration_set" "smtp" {
  configuration_set_name = "${var.project_slug}-smtp"
}

resource "aws_sesv2_email_identity" "smtp" {
  email_identity         = local.fqdn
  configuration_set_name = aws_sesv2_configuration_set.smtp.configuration_set_name
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

# SPF is not implemented: DMARC only requires one of SPF or DKIM to align, and DKIM is sufficient.
# SES uses its own MAIL FROM domain by default, so SPF alignment would require a custom MAIL FROM:
# https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-spf.html

resource "aws_route53_record" "smtp_dmarc" {
  zone_id = var.route53_zone_id
  name    = "_dmarc.${local.fqdn}"
  type    = "TXT"
  ttl     = 300
  records = [join("", concat(
    ["v=DMARC1; p=quarantine;"],
    # "psd" is defined by the new https://datatracker.ietf.org/doc/html/rfc9989
    var.dmarc_boundary ? [" psd=n;"] : [],
  ))]
}

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
    resources = [
      # Both are required
      aws_sesv2_email_identity.smtp.arn,
      aws_sesv2_configuration_set.smtp.arn,
    ]
    actions = ["ses:SendRawEmail"]
  }
}
