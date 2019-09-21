#
# Beschreibung des Ansible Masters
#

#
# Zugriff auf IP-Pool einrichten
#
data "terraform_remote_state" "ip_pool" {
  backend = "s3"
  config = {
	#encrypt = true
	bucket = "dl-terraform-state"
	region = "eu-central-1"
	key = "Network/IP-Pool/terraform.tfstate"
  }
}

#
# Zugriff auf IDs der Subnetze einrichten
#
data "terraform_remote_state" "subnetze" {
  backend = "s3"
  config = {
	#encrypt = true
	bucket = "dl-terraform-state"
	region = "eu-central-1"
	key = "Network/SIT/terraform.tfstate"
  }
}

#
# Cloud Config um Pakete zu installieren und User anzulegen
#
data "template_file" "cloud_config" {
  template = "${file("${var.cloud_init_conf}")}"
}

#
# Anlegen des Ansible Servers
#

resource "aws_instance" "awx" {
  ami = var.aws_centos_ami[var.aws_region]
  instance_type = var.instance_type
  subnet_id = "${data.terraform_remote_state.subnetze.outputs.DL_SN_INFRAS_PRIV_AZ1}"

  # ssh_key definieren
  key_name = aws_key_pair.awx_key.key_name

  vpc_security_group_ids = [aws_security_group.SG_awx.id]

  tags = {
    Name = "AWX CentOS"
  }

  user_data	 = "${data.template_file.cloud_config.rendered}"
}

#
# IP Adresse aus Pool zuweisen
#

resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.awx.id}"
  allocation_id = "${data.terraform_remote_state.ip_pool.outputs.EIP_Pool[1].id}"
}