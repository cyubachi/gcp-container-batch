// Add Cloud Run service for creating batch container.
resource "google_cloud_run_service" "run_container_on_gce" {
  name = "run-container-on-gce"
  project = var.project_id
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/gcp-container-batch:latest"
      }
      timeout_seconds = 1800
    }
  }
  autogenerate_revision_name = true
}
