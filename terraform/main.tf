terraform {
  backend "gcs" {
  }
}

provider "google" {
  credentials = file(var.credential)
  project = var.project_id
  region = var.region
}
