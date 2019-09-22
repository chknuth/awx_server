resource "aws_security_group" "SG_awx" {
  name        = "SG_awx"
  description = "Security Group for AWX Server"
  
  vpc_id     = "${data.terraform_remote_state.subnetze.outputs.DL_VPC_ID}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8052
    to_port     = 8052
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG_awx"
  }
}