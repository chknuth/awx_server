resource "aws_key_pair" "awx_key" {
  key_name   = "awx_root_key"
  public_key = file("${var.aws_ssh_admin_key_file}.pub")
}

