data "heroku_team" "heroku" {
  name = var.team_name
}

resource "heroku_app" "heroku" {
  name   = var.app_name
  region = "us"
  organization {
    name = data.heroku_team.heroku.name
  }
  buildpacks = concat(
    [
      # "ianpurvis/heroku-buildpack-version", to provide SOURCE_VERSION, for use by Sentry.
      # Set it first to provide SOURCE_VERSION for other buildpacks.
      # This buildpack isn't registered, so get it directly from the Git repo, as setting the
      # name alone isn't stable with Terraform.
      "https://github.com/ianpurvis/heroku-buildpack-version.git",
    ],
    var.additional_buildpacks,
    [
      # The buildpack for the primary language must come last
      # https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app#adding-a-buildpack
      "heroku/python",
    ]
  )
  acm = true # SSL certs for custom domain

  # Auto-created (by addons) config vars:
  # * CLOUDAMQP_APIKEY
  # * CLOUDAMQP_URL
  # * DATABASE_URL
  # * PAPERTRAIL_API_TOKEN
  config_vars           = var.config_vars
  sensitive_config_vars = var.sensitive_config_vars
}

resource "heroku_formation" "heroku_web" {
  app_id   = heroku_app.heroku.id
  type     = "web"
  size     = var.web_dyno_size
  quantity = var.web_dyno_quantity
}

resource "heroku_formation" "heroku_worker" {
  app_id   = heroku_app.heroku.id
  type     = "worker"
  size     = var.worker_dyno_size
  quantity = var.worker_dyno_quantity
}

resource "heroku_addon" "heroku_postgresql" {
  count  = var.postgresql_plan == null ? 0 : 1
  app_id = heroku_app.heroku.id
  plan   = "heroku-postgresql:${var.postgresql_plan}"
}

resource "heroku_addon" "heroku_cloudamqp" {
  count  = var.cloudamqp_plan == null ? 0 : 1
  app_id = heroku_app.heroku.id
  plan   = "cloudamqp:${var.cloudamqp_plan}"
}

resource "heroku_addon" "heroku_papertrail" {
  count  = var.papertrail_plan == null ? 0 : 1
  app_id = heroku_app.heroku.id
  plan   = "papertrail:${var.papertrail_plan}"
}

resource "heroku_domain" "heroku" {
  app_id   = heroku_app.heroku.id
  hostname = var.fqdn
}
