#GKE cluster
module "hntech-cluster" {
  source     = "./gke"
  env_name   = var.env_name
  project_id = var.project_id
}

#Pub/Sub topic
resource "google_pubsub_topic" "ht_topic" {
  name    = var.topic
  project = var.project_id
}

#Pub/Sub subscription
resource "google_pubsub_subscription" "ht_subscription" {
  name                 = var.subscription_name
  project              = var.project_id
  topic                = google_pubsub_topic.ht_topic.name
  ack_deadline_seconds = var.ack_deadline_seconds
}

resource "google_pubsub_topic_iam_binding" "binding" {
  topic   = google_pubsub_topic.ht_topic.name
  project = var.project_id
  role    = var.role
  members = ["serviceAccount:${var.sa_email}"]
}

resource "google_storage_notification" "notification" {
  bucket         = google_storage_bucket.sbucket.name
  payload_format = var.payload_format
  topic          = google_pubsub_topic.ht_topic.id
  event_types    = var.event_types
  depends_on = [
    google_pubsub_topic_iam_binding.binding
  ]
}

resource "google_storage_bucket" "sbucket" {
  name                        = var.sbucket
  project                     = var.sproject
  uniform_bucket_level_access = var.uniform_bucket_level_access
  location                    = var.location
  force_destroy = true
}

resource "google_service_account" "sa" {
  account_id   = var.account_id
  display_name = var.display_name
  project      = var.project_id
}

resource "google_project_iam_member" "pubsub-sub" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

data "google_iam_policy" "binding" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "serviceAccount:${google_service_account.sa.email}",
    ]
  }

}