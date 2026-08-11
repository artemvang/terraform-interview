output "bucket_name" {
  description = "google_storage_bucket.google_storage_bucket_target_bucket.name"
  value       = "${google_storage_bucket.google_storage_bucket_target_bucket.name}"
}
