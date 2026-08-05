# Required variables
variable "project_slug" {
  type        = string
  nullable    = false
  description = "A slugified name, used to label resources."
  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.project_slug))
    error_message = "The \"project_slug\" value must be lowercase alphanumeric words, separated by hyphens."
  }
}

variable "subdomain_name" {
  type        = string
  nullable    = false
  description = "The DNS subdomain name where the server will be available."
  validation {
    # This is prepended to the zone's name, so it must not be fully-qualified
    condition     = can(regex("^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$", var.subdomain_name))
    error_message = "The \"subdomain_name\" value must be a relative DNS name, with no trailing dot."
  }
}

variable "heroku_team_name" {
  type        = string
  nullable    = false
  description = "The name of the Heroku team for the app."
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

variable "django_settings_module" {
  type        = string
  nullable    = false
  description = "The import path used to set DJANGO_SETTINGS_MODULE."
  validation {
    # The second condition rejects file paths, which would otherwise look like import paths
    condition = (
      can(regex("^[a-zA-Z_][a-zA-Z0-9_]*(\\.[a-zA-Z_][a-zA-Z0-9_]*)*$", var.django_settings_module))
      && !can(regex("\\.py$", var.django_settings_module))
    )
    error_message = "The \"django_settings_module\" value must be a Python import path, not a file path."
  }
}

# Optional variables
variable "heroku_app_name" {
  type        = string
  nullable    = true
  default     = null # Effective default is set internally
  description = "The name of the Heroku app."
}

variable "heroku_additional_buildpacks" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Additional buildpacks to use on Heroku."
}

variable "storage_bucket_name" {
  type        = string
  nullable    = true
  default     = null # Effective default is set internally
  description = "The globally unique S3 bucket name of the storage."
}

variable "django_default_from_email" {
  type        = string
  nullable    = true
  default     = null # Effective default is set internally
  description = "The default email address which Django will send from."
  validation {
    # Django also allows a display name, like "Example <admin@example.com>"
    condition     = var.django_default_from_email == null || can(regex("^[^<>@\\s]+@[^<>@\\s]+$|<[^<>@\\s]+@[^<>@\\s]+>$", var.django_default_from_email))
    error_message = "The \"django_default_from_email\" value must be an email address."
  }
}

variable "django_cors_allowed_origins" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Domains which Django will allow to make CORS requests."
  validation {
    # django-cors-headers requires a scheme and no path; the values are also joined with commas
    condition     = alltrue([for origin in var.django_cors_allowed_origins : can(regex("^https?://[^/,\\s]+$", origin))])
    error_message = "Each \"django_cors_allowed_origins\" value must include a scheme and have no trailing slash."
  }
}
variable "django_cors_allowed_origin_regexes" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Domain regular expressions which Django will allow to make CORS requests."
}

variable "additional_django_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Additional Django environment variables."
}
variable "additional_sensitive_django_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Additional Django environment variables, which will not be printed."
  sensitive   = true
}

variable "heroku_web_dyno_size" {
  type        = string
  nullable    = false
  default     = "basic"
  description = "The Heroku web server dyno size."
}

variable "heroku_web_dyno_quantity" {
  type        = number
  nullable    = false
  default     = 1
  description = "The Heroku web server dyno quantity."
}

variable "heroku_worker_dyno_size" {
  type        = string
  nullable    = false
  default     = "basic"
  description = "The Heroku worker dyno size."
}

variable "heroku_worker_dyno_quantity" {
  type        = number
  nullable    = false
  default     = 1
  description = "The Heroku worker dyno quantity."
}

variable "heroku_postgresql_plan" {
  type        = string
  nullable    = true
  default     = "essential-0"
  description = "The Heroku Postgres add-on plan type, or null to disable."
}

variable "heroku_cloudamqp_plan" {
  type        = string
  nullable    = true
  default     = "lemur"
  description = "The Heroku CloudAMQP add-on plan type, or null to disable."
}

variable "heroku_papertrail_plan" {
  type        = string
  nullable    = true
  default     = "choklad"
  description = "The Heroku Papertrail add-on plan type, or null to disable."
}

variable "ec2_worker_ssh_public_key" {
  type        = string
  nullable    = true
  default     = null
  description = "An SSH public key, to be installed on the EC2 workers. This must be set if ec2_worker_instance_quantity > 0."
  validation {
    # The key's format is validated by the "ec2_worker" module
    condition     = var.ec2_worker_instance_quantity <= 0 || var.ec2_worker_ssh_public_key != null
    error_message = "The \"ec2_worker_ssh_public_key\" value must be set if \"ec2_worker_instance_quantity\" is greater than 0."
  }
}

variable "ec2_worker_instance_type" {
  type        = string
  nullable    = false
  default     = "t3.small"
  description = "The EC2 workers' instance size."
}

variable "ec2_worker_instance_quantity" {
  type        = number
  nullable    = false
  default     = 0
  description = "The quantity of EC2 worker instances."
  validation {
    # The "ec2_worker" module validates this too, but it isn't instantiated without any workers
    condition     = var.ec2_worker_instance_quantity >= 0 && var.ec2_worker_instance_quantity == floor(var.ec2_worker_instance_quantity)
    error_message = "The \"ec2_worker_instance_quantity\" value must be a non-negative integer."
  }
}

variable "ec2_worker_volume_size" {
  type        = number
  nullable    = false
  default     = 40
  description = "The size, in GB, of the root EBS volume for the EC2 workers."
}

variable "ec2_worker_launch_ami_id" {
  type        = string
  nullable    = true
  default     = null # Effective default is set internally
  description = "The AMI ID used to initially launch the EC2 workers. Changing this will not replace existing instances."
}
