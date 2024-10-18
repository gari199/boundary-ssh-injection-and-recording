# Create an organisation scope within global, named "ops-org"
# The global scope can contain multiple org scopes
resource "boundary_scope" "org" {
  scope_id                 = "global"
  name                     = "demo-org"
  description              = "Demo Org"
  auto_create_default_role = true
  auto_create_admin_role   = true
}

/* Create a project scope within the "ops-org" organsiation
Each org can contain multiple projects and projects are used to hold
infrastructure-related resources
*/
resource "boundary_scope" "project" {
  name                     = "demo-project"
  description              = "Demo Project"
  scope_id                 = boundary_scope.org.id
  auto_create_admin_role   = true
  auto_create_default_role = true
}

# Create a Static Host Catalog called DevOps for targets to be associated with.
resource "boundary_host_catalog_static" "demo_host_catalog" {
  name        = "demo-host-catalogue"
  description = "Demo Host Catalogue"
  scope_id    = boundary_scope.project.id
}

# Creates a dynamic host catalog for AWS
resource "boundary_host_catalog_plugin" "aws_plugin" {
  name        = "AWS Catalog"
  description = "AWS Host Catalog"
  scope_id    = boundary_scope.project.id
  plugin_name = "aws"
  attributes_json = jsonencode({
    "region" = "eu-west-2",
  "disable_credential_rotation" = true })


  secrets_json = jsonencode({
    "access_key_id"     = var.aws_access,
    "secret_access_key" = var.aws_secret
  })
}

/* The below three resources create dynamic host sets. The attributes_json defines the tags that Boundary
will look for to automatically pull into Boundary as resources to access. The EC2 instances for this currently
reside within the aws-dhc-targets folder. The preferred_endpoints addresses need to be changed to use string
interpolation to reference them properly.
*/
resource "boundary_host_set_plugin" "aws-db" {
  name                  = "AWS DB Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:service-type=database" })
  sync_interval_seconds = 30
}

resource "boundary_host_set_plugin" "aws-dev" {
  name                  = "AWS Dev Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:application=dev" })
  sync_interval_seconds = 30
}

resource "boundary_host_set_plugin" "aws-prod" {
  name                  = "AWS Prod Host Set Plugin"
  host_catalog_id       = boundary_host_catalog_plugin.aws_plugin.id
  preferred_endpoints   = ["cidr:0.0.0.0/0"]
  attributes_json       = jsonencode({ "filters" = "tag:application=production" })
  sync_interval_seconds = 30
}

resource "boundary_target" "aws" {
  type                     = "ssh"
  name                     = "aws-ec2"
  description              = "AWS EC2 Targets"
  egress_worker_filter     = " \"self-managed-aws-worker\" in \"/tags/type\" "
  scope_id                 = boundary_scope.project.id
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_plugin.aws-db.id,
    boundary_host_set_plugin.aws-dev.id,
    boundary_host_set_plugin.aws-prod.id,
  ]
/*   enable_session_recording = true
  storage_bucket_id = boundary_storage_bucket.boundary_storage_bucket.id */
  injected_application_credential_source_ids = [boundary_credential_ssh_private_key.static_ssh_key.id]
}