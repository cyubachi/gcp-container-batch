// Add Cloud Run trigger PubSub
resource "google_pubsub_topic" "create_batch_instance_topic" {
  name = "create-batch-instance-topic"
}

resource "google_pubsub_subscription" "create_batch_instance_subscription" {
  name = "create-batch-instance-subscription"
  topic = google_pubsub_topic.create_batch_instance_topic.name
  ack_deadline_seconds = 600
  push_config {
    push_endpoint = google_cloud_run_service.run_container_on_gce.status[0].url
    oidc_token {
      service_account_email = google_service_account.pubsub_message_publisher.email
    }
  }
}
