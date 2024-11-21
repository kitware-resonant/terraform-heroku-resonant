# Required variables
variable "project_slug" {
  type        = string
  nullable    = false
  description = "A slugified name, used to label resources."
}

variable "subdomain_name" {
  type        = string
  nullable    = false
  description = "The DNS subdomain name where the server will be available."
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
}

variable "django_cors_origin_whitelist" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Domains which Django will allow to make CORS requests."
}
variable "django_cors_origin_regex_whitelist" {
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
  default     = "basic"
  description = "The Heroku Postgres add-on plan type, or null to disable."
}

variable "heroku_redis_plan" {
  type        = string
  nullable    = true
  default     = "mini"
  description = "The Heroku Data for Redis add-on plan type, or null to disable."
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
