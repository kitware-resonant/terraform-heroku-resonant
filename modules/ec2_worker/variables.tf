variable "project_slug" {
  type        = string
  nullable    = false
  description = "A slugified name, used to label AWS resources."
  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.project_slug))
    error_message = "The \"project_slug\" value must be lowercase alphanumeric words, separated by hyphens."
  }
}

variable "ssh_public_key" {
  type        = string
  nullable    = false
  description = "An SSH public key, to be installed on the EC2 workers."
  validation {
    # EC2 only supports RSA and ED25519 keys:
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html
    condition     = can(regex("^(ssh-rsa|ssh-ed25519) ", var.ssh_public_key))
    error_message = "The \"ssh_public_key\" value must be an OpenSSH-formatted RSA or ED25519 public key."
  }
}

variable "instance_type" {
  type        = string
  nullable    = false
  default     = "t3.small"
  description = "The EC2 workers' instance size."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "The \"instance_type\" value must be an EC2 instance type, like \"t3.small\"."
  }
}

variable "instance_quantity" {
  type        = number
  nullable    = false
  default     = 1
  description = "The quantity of EC2 worker instances."
  validation {
    condition     = var.instance_quantity >= 0 && var.instance_quantity == floor(var.instance_quantity)
    error_message = "The \"instance_quantity\" value must be a non-negative integer."
  }
}

variable "volume_size" {
  type        = number
  nullable    = false
  default     = 40
  description = "The size, in GB, of the root EBS volume for the EC2 workers."
  validation {
    # The lower bound is the default AMI's snapshot size, the upper bound is the gp3 volume maximum
    condition     = var.volume_size >= 8 && var.volume_size <= 16384 && var.volume_size == floor(var.volume_size)
    error_message = "The \"volume_size\" value must be an integer between 8 and 16384."
  }
}

variable "launch_ami_id" {
  type        = string
  nullable    = true
  default     = null # Effective default is set internally
  description = "The AMI ID used to initially launch the EC2 workers. Changing this will not replace existing instances."
  validation {
    condition     = var.launch_ami_id == null || can(regex("^ami-([0-9a-f]{8}|[0-9a-f]{17})$", var.launch_ami_id))
    error_message = "The \"launch_ami_id\" value must be an AMI ID, like \"ami-0123456789abcdef0\"."
  }
}
