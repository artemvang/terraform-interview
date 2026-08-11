locals {
  scalr_version = replace(var.scalr_version, ".", "-") # bucket names cannot contain dots (allowed only for the domains)
}

data "google_storage_bucket" "google_storage_bucket_frontend" {
  name = "scalr.frontend-${local.scalr_version}"
}

resource "google_storage_bucket" "google_storage_bucket_target_bucket" {
  name                        = "scalr.frontend-${var.scalr_id}"
  location                    = "US"
  storage_class               = "MULTI_REGIONAL"
  force_destroy               = false
  uniform_bucket_level_access = false

  retention_policy {
    retention_period = 60 * 5
  }

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "terraform_data" "terraform_data_copy_frontend" {
  provisioner "local-exec" {
    working_dir = "${path.module}/bin/"
    command     = "./copy ${data.google_storage_bucket.google_storage_bucket_frontend.name} ${google_storage_bucket.google_storage_bucket_target_bucket.name}"
  }
  triggers_replace = [
    data.google_storage_bucket.google_storage_bucket_frontend.name,
    google_storage_bucket.google_storage_bucket_target_bucket.name
  ]

  depends_on = [google_storage_bucket.google_storage_bucket_target_bucket]
}

data "google_iam_policy" "google_iam_policy" {
  binding {
    role    = "roles/storage.objectAdmin"
    members = ["allUsers"]
  }
}

resource "google_storage_bucket_iam_policy" "google_storage_bucket_iam_policy" {
  bucket      = google_storage_bucket.google_storage_bucket_target_bucket.name
  policy_data = data.google_iam_policy.google_iam_policy.policy_data

  depends_on = [terraform_data.terraform_data_copy_frontend]
}
