//A native Boundary static credential store
resource "boundary_credential_store_static" "static_cred_store" {
  name        = "static_credential_store"
  description = "Boundary Static Credential Store"
  scope_id    = boundary_scope.project.id
}

//A native username/password in Boundary
resource "boundary_credential_ssh_private_key" "static_ssh_key" {
  name                = "static-ssh-key"
  description         = "Boundary Static SSH credential"
  credential_store_id = boundary_credential_store_static.static_cred_store.id
  username            = "ec2-user"           //Change this to your username
  private_key         = file("boundary.pem") //Change this to your .pem file name
}