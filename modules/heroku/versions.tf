terraform {
  required_version = ">= 1.1"

  required_providers {
    heroku = {
      source  = "heroku/heroku"
      version = ">= 5.0.0"
    }
  }
}

moved {
  from = heroku_addon.heroku_postgresql
  to   = heroku_addon.heroku_postgresql[0]
}
moved {
  from = heroku_addon.heroku_papertrail
  to   = heroku_addon.heroku_papertrail[0]
}
