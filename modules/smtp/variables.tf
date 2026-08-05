variable "project_slug" {
  type        = string
  nullable    = false
  description = "A slugified name, used to label AWS resources."
  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.project_slug))
    error_message = "The \"project_slug\" value must be lowercase alphanumeric words, separated by hyphens."
  }
}

variable "route53_zone_id" {
  type        = string
  nullable    = false
  description = "The Route 53 zone ID to create new DNS records within."
  validation {
    # Providing the zone's name instead of its ID is a common mistake
    condition     = can(regex("^Z[A-Z0-9]+$", var.route53_zone_id))
    error_message = "The \"route53_zone_id\" value must be a Route 53 zone ID, not a domain name."
  }
}

variable "fqdn" {
  type        = string
  nullable    = false
  description = "The fully-qualified domain name for outgoing emails."
  validation {
    # Route 53 zone names are returned lowercase and without a trailing dot
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.fqdn))
    error_message = "The \"fqdn\" value must be a lowercase fully-qualified domain name, with no trailing dot."
  }
}

variable "dmarc_boundary" {
  type        = bool
  nullable    = false
  default     = false
  description = "Prevent a parent domain's DMARC policy from overriding this one."
}

variable "dmarc_rua" {
  type        = string
  nullable    = true
  default     = null
  description = "Reporting URI(s) (starting with \"mailto:\") for DMARC aggregate feedback reports."
  validation {
    # "||" does not short-circuit, but "can" suppresses the error from "regex" with a null value
    condition     = var.dmarc_rua == null || can(regex("^mailto:[^\\s,]+(\\s*,\\s*mailto:[^\\s,]+)*$", var.dmarc_rua))
    error_message = "The \"dmarc_rua\" value must be a comma-separated list of \"mailto:\" URIs."
  }
}
