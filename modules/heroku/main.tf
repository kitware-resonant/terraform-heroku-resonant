data "heroku_team" "heroku" {
  name = var.team_name
}

resource "heroku_app" "heroku" {
  name   = var.app_name
  region = "us"
  organization {
    name = data.heroku_team.heroku.name
  }
  # The buildpack for the primary language must come last
  # https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app#adding-a-buildpack
  buildpacks = concat(var.additional_buildpacks, ["heroku/python"])
  acm        = true # SSL certs for custom domain

  # Auto-created (by addons) config vars:
  # * DATABASE_URL
  # * PAPERTRAIL_API_TOKEN
  # * REDIS_URL
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

resource "heroku_addon" "heroku_redis" {
  count  = var.redis_plan == null ? 0 : 1
  app_id = heroku_app.heroku.id
  plan   = "heroku-redis:${var.redis_plan}"
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
