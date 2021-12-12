// Grant token creator role to default pubsub service account.
resource "google_project_iam_member" "cloudrun_invoker" {
  project = var.project_id
  member = "serviceAccount:service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  role = "roles/iam.serviceAccountTokenCreator"
}

// Add message publisher service account.
resource "google_service_account" "pubsub_message_publisher" {
  project = var.project_id
  account_id = "pubsub-message-publisher"
}

resource "google_project_iam_member" "pubsub_message_publisher" {
  project = var.project_id
  role = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.pubsub_message_publisher.email}"
}


// List of users who can invoke cloud run.
data "google_iam_policy" "allow_cloud_run_invoke_policy" {
  binding {
    role = "roles/run.invoker"
    // Add user who can invoke cloud run.
    members = [
      "serviceAccount:${google_service_account.pubsub_message_publisher.email}",
    ]
  }
}

// Grant cloud run invoker role to users who can invoke cloud run.
resource "google_cloud_run_service_iam_policy" "allow_cloud_run_invoke" {
  location = google_cloud_run_service.run_container_on_gce.location
  project = var.project_id
  service = google_cloud_run_service.run_container_on_gce.name
  policy_data = data.google_iam_policy.allow_cloud_run_invoke_policy.policy_data
}
