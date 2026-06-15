variable "project_slug" {
  type        = string
  nullable    = false
  description = "A slugified name, used to label AWS resources."
}

variable "route53_zone_id" {
  type        = string
  nullable    = false
  description = "The Route 53 zone ID to create new DNS records within."
}

variable "fqdn" {
  type        = string
  nullable    = false
  description = "The fully-qualified domain name for outgoing emails."
}

variable "dmarc_boundary" {
  type        = bool
  nullable    = false
  default     = false
  description = "Prevent a parent domain's DMARC policy from overriding this one."
}
