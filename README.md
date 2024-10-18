# hcpb-static-ssh-injection
Utilising HashiCorp Boundary's static credential store to hold a static .pem file and inject into a session with session recording enababled

KEEP COMMENTED in hcpb-storage-bucket SECTION and session recorder configuration in boundary-config during the first apply. Wait for Worker IP to show up to indicate it authenticated to the controller before uncomment these sections and doind terraform apply again.

In order to delete:

