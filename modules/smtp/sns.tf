resource "aws_sns_topic" "smtp_sns" {
  name              = "${var.project_slug}-smtp-failures"
  signature_version = 2
}

resource "aws_sns_topic_policy" "smtp_sns" {
  arn    = aws_sns_topic.smtp_sns.arn
  policy = data.aws_iam_policy_document.smtp_sns.json
}

data "aws_iam_policy_document" "smtp_sns" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.smtp_sns.arn]
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_sesv2_configuration_set.smtp.arn]
    }
  }
}

resource "aws_sesv2_configuration_set_event_destination" "smtp_sns" {
  configuration_set_name = aws_sesv2_configuration_set.smtp.configuration_set_name
  event_destination_name = "failures"

  event_destination {
    sns_destination {
      topic_arn = aws_sns_topic.smtp_sns.arn
    }
    enabled              = true
    matching_event_types = ["BOUNCE", "COMPLAINT", "REJECT"]
  }
}
