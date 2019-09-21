# AWS Region definieren
provider "aws" {
  region = "eu-central-1"
}

# Ermitteln der Availibiltiy Zones
data "aws_availability_zones" "all" {
}

