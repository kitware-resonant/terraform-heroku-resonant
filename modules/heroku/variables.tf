variable "team_name" {
  type        = string
  nullable    = false
  description = "The name of the team for the app."
}

variable "app_name" {
  type        = string
  nullable    = false
  description = "The name of the app."
  validation {
    # https://devcenter.heroku.com/articles/creating-apps#creating-a-named-app
    condition     = can(regex("^[a-z][a-z0-9-]{2,29}$", var.app_name))
    error_message = "The \"app_name\" value must start with a letter and be 3 to 30 lowercase letters, digits, and hyphens."
  }
}

variable "fqdn" {
  type        = string
  nullable    = false
  description = "The fully-qualified domain name of the app."
  validation {
    # Route 53 zone names are returned lowercase and without a trailing dot
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.fqdn))
    error_message = "The \"fqdn\" value must be a lowercase fully-qualified domain name, with no trailing dot."
  }
}

# Optional variables
variable "config_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "App environment variables, which will not be printed."
  validation {
    condition     = alltrue([for name in keys(var.config_vars) : can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", name))])
    error_message = "Each \"config_vars\" key must be a valid environment variable name."
  }
}

variable "sensitive_config_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "App environment variables."
  sensitive   = true
  validation {
    condition     = alltrue([for name in keys(var.sensitive_config_vars) : can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", name))])
    error_message = "Each \"sensitive_config_vars\" key must be a valid environment variable name."
  }
}

variable "additional_buildpacks" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Additional buildpacks to use."
}

variable "web_dyno_size" {
  type        = string
  nullable    = false
  default     = "basic"
  description = "The web server dyno size."
}

variable "web_dyno_quantity" {
  type        = number
  nullable    = false
  default     = 1
  description = "The web server dyno quantity."
  validation {
    condition     = var.web_dyno_quantity >= 0 && var.web_dyno_quantity == floor(var.web_dyno_quantity)
    error_message = "The \"web_dyno_quantity\" value must be a non-negative integer."
  }
}

variable "worker_dyno_size" {
  type        = string
  nullable    = false
  default     = "basic"
  description = "The worker dyno size."
}

variable "worker_dyno_quantity" {
  type        = number
  nullable    = false
  default     = 1
  description = "The worker dyno quantity."
  validation {
    condition     = var.worker_dyno_quantity >= 0 && var.worker_dyno_quantity == floor(var.worker_dyno_quantity)
    error_message = "The \"worker_dyno_quantity\" value must be a non-negative integer."
  }
}

variable "postgresql_plan" {
  type        = string
  nullable    = true
  default     = "essential-0"
  description = "The Postgres add-on plan type, or null to disable."
}

variable "cloudamqp_plan" {
  type        = string
  nullable    = true
  default     = "lemur"
  description = "The CloudAMQP add-on plan type, or null to disable."
}

variable "papertrail_plan" {
  type        = string
  nullable    = true
  default     = "choklad"
  description = "The Papertrail add-on plan type, or null to disable."
}
