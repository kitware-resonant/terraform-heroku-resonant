# terraform-heroku-resonant
A Terraform module to provision Kitware Resonant infrastructure on Heroku + AWS.

This facilitates deployment of Django applications created from the
[Resonant cookiecutter](https://github.com/kitware-resonant/cookiecutter-resonant).
It creates a Heroku app with addons for
[PostgreSQL](https://elements.heroku.com/addons/heroku-postgresql),
[Redis](https://elements.heroku.com/addons/heroku-redis),
and [Papertrail](https://elements.heroku.com/addons/papertrail).
It also creates
[AWS S3](https://aws.amazon.com/s3/) storage,
[outgoing SMTP](https://aws.amazon.com/ses/) credentials,
and an optional [AWS EC2](https://aws.amazon.com/ec2/) worker.

See [full usage documentation at Terraform Registry](https://registry.terraform.io/modules/kitware-resonant/resonant/heroku).

## Note on AWS Email Sending
[Every AWS account must explicitly apply to send real emails](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html),
once per Simple Email Service (SES) region.

Approvals seem to be granted liberally and to take about 24 hours.

## Note on initial creation of Heroku apps
When first creating an instance of this module, provisioning of the Heroku app
(specifically the `heroku_formation` resources) will likely fail with a
"Couldn't find that process type" error message. To resolve this, the Heroku app
code must be deployed at least once.

Typically, this can be done by
[connecting a GitHub repo to the Heroku app](https://devcenter.heroku.com/articles/github-integration#enabling-github-integration)
and then
[triggering a manual deploy](https://devcenter.heroku.com/articles/github-integration#manual-deploys).
Finally, run `terraform apply` again, which should succeed.

Afterwards, it's advisable to also
[set up automatic deploys](https://devcenter.heroku.com/articles/github-integration#automatic-deploys).

## Note on EC2 Worker AMIs
Newly launched EC2 worker instances will use the latest AMI at the time of launch, but
existing instances will not be replaced when a newer AMI is available. Thus, incrementally scaling
up the `ec2_worker_instance_quantity` variable may result in multiple instances with slightly
different AMIs.

Likewise, setting or changing the optional variable `ec2_worker_launch_ami_id` will only affect
newly launched instances, but will also not trigger the replacement of any existing instances with
a different AMI.

Use [the `-replace` option](https://developer.hashicorp.com/terraform/cli/commands/plan#replace-address)
with the `module.<resonant>.module.ec2_worker[0].aws_instance.ec2_worker[*]` target (where
`<resonant>` is the local name of this module) to force the replacement of all existing instances.
