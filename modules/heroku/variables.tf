variable "team_name" {
  type        = string
  nullable    = false
  description = "The name of the team for the app."
}

variable "app_name" {
  type        = string
  nullable    = false
  description = "The name of the app."
}

variable "fqdn" {
  type        = string
  nullable    = false
  description = "The fully-qualified domain name of the app."
}

# Optional variables
variable "config_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "App environment variables, which will not be printed."
}

variable "sensitive_config_vars" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "App environment variables."
  sensitive   = true
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
}

variable "postgresql_plan" {
  type        = string
  nullable    = true
  default     = "essential-0"
  description = "The Postgres add-on plan type, or null to disable."
}

variable "redis_plan" {
  type        = string
  nullable    = true
  default     = "mini"
  description = "The Heroku Data for Redis add-on plan type, or null to disable."
}

variable "papertrail_plan" {
  type        = string
  nullable    = true
  default     = "choklad"
  description = "The Papertrail add-on plan type, or null to disable."
}
