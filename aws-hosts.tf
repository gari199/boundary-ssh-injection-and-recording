resource "aws_instance" "boundary_public_target" {
  ami               = "ami-09ee0944866c73f62"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2b"
  key_name          = data.aws_key_pair.boundary-host.key_name //Change this to your key name


  network_interface {
    network_interface_id = aws_network_interface.boundary_public_target_ni.id
    device_index         = 0
  }
  tags = {
    Name         = "boundary-1-dev",
    service-type = "database",
    application  = "dev",
  }
}

resource "aws_network_interface" "boundary_public_target_ni" {
  subnet_id               = aws_subnet.boundary_ingress_worker_subnet.id
  security_groups         = [aws_security_group.static_target_sg.id]
  private_ip_list_enabled = false
}

data "aws_key_pair" "boundary-host" {
  key_name           = "boundary-host"
  include_public_key = true
}