# Frontend deployment

This code introduces new feature into project: static site building and terraform module for frontend deploying using GCP bucket.

Deployment stages:

1. Build frontend artifacts and push them to newly created artifacts bucket (`scalr-frontend-1.0.0`).
2. Apply terraform code, which creates target bucket (`scalr-frontend-blue|green`), rsyncs frontend from artifacts bucket to target bucket and sets permissions.
3. Behind the curtains load balancer switches traffic to be served using fresh target bucket.