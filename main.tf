terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "long_running_tasks_in_apache_airflow" {
  source    = "./modules/long_running_tasks_in_apache_airflow"

  providers = {
    shoreline = shoreline
  }
}