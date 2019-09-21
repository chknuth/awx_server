terraform {
	backend "s3" {
		encrypt = true
		bucket = "dl-terraform-state"
		region = "eu-central-1"
		key = "DevOps/awx/terraform.tfstate"
	}
}
