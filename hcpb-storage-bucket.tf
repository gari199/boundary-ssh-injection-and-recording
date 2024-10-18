/**
After the main Terraform code has been run, uncomment out this section and lines 89+90 in boundary-config.tf file.
This is due to a race condition where the worker needs to be up and established to the controll plane before
a storage bucket can be created.

Note - With the current Boundary Terraform provider, you will need to manually remove the HCPb Storage Bucket
via the CLI before running a Terraform destroy
Wait for Worker IP to show up to indicate it authenticated to the controller before applying this and sess record config
**/

/* resource "boundary_storage_bucket" "boundary_storage_bucket" {
   name            = "${random_pet.unique_names.id}-session-recording-bucket"
   scope_id        = "global"
   plugin_name     = "aws"
   bucket_name     = aws_s3_bucket.boundary_session_recording_bucket.bucket
   attributes_json = jsonencode({ "region" = "eu-west-2", "disable_credential_rotation" = true })

   secrets_json = jsonencode({
     "access_key_id"     = var.aws_access,
     "secret_access_key" = var.aws_secret
   })
   worker_filter = " \"self-managed-aws-worker\" in \"/tags/type\" "
} */