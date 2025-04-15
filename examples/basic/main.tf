provider "aws" {
  region = "us-east-1"
  # Must set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY envvars
}
provider "heroku" {
  # Must set HEROKU_EMAIL, HEROKU_API_KEY envvars
}

data "aws_route53_zone" "this" {
  # This must be created by hand in the AWS console
  name = "rootdomain.test"
}

data "heroku_team" "this" {
  # This must be created by hand in the Heroku console
  name = "heroku_team"
}

data "local_file" "ssh_public_key" {
  # This must be an existing file on the local filesystem
  filename = "/home/user/.ssh/id_rsa.pub"
}

# This provides a zero-configuration option for assigning names,
# but most projects will want to select a more specific name instead
resource "random_pet" "instance_name" {
  prefix    = "resonant"
  length    = 2
  separator = "-"
}

module "resonant" {
  source = "kitware-resonant/resonant/heroku"

  project_slug           = random_pet.instance_name.id
  route53_zone_id        = data.aws_route53_zone.this.zone_id
  heroku_team_name       = data.heroku_team.this.name
  subdomain_name         = random_pet.instance_name.id
  django_settings_module = "resonant.settings.heroku_production"

  // Provisional an optional EC2 worker too
  ec2_worker_ssh_public_key    = data.local_file.ssh_public_key.content
  ec2_worker_instance_quantity = 1
}

output "fqdn" {
  value = module.resonant.fqdn
}
output "heroku_app_id" {
  value = module.resonant.heroku_app_id
}
output "heroku_iam_user_id" {
  value = module.resonant.heroku_iam_user_id
}
output "storage_bucket_name" {
  value = module.resonant.storage_bucket_name
}
output "ec2_worker_hostnames" {
  value = module.resonant.ec2_worker_hostnames
}
output "ec2_worker_iam_role_id" {
  value = module.resonant.ec2_worker_iam_role_id
}
