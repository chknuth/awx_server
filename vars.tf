#
# Allgemeine Definitionen zum Provider AWS
#

# Die Region, in der die Infrastruktur erstellt wird
variable "aws_region" {
  description = "Region in AWS"
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "The instance type for the ansible server"
  default     = "t2.medium"
}

# key file für den admin auf dem Ansible server
variable "aws_ssh_admin_key_file" {
  description = "name of the key file"
  default     = "keys/awx_root"
}

# Name der Cloud_init Datei
variable "cloud_init_conf" {
  description	= "Name der Datei mit den Cloud-init Konfigurationen"
	default		= "cloud-config.yml"
}

variable "aws_centos_ami" {
  type = map(string)

  default = {
    eu-central-1 = "ami-0be110ffd53859e30"
  }
}
