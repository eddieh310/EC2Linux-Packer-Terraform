packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  # Format: YYYYMMDD-HHMM
  timestamp       = formatdate("YYYY-MM-DD--HH-mm", timestamp())
  ami_target_name = "Linux-AMI-${local.timestamp}"
}

source "amazon-ebs" "mylinux" {
  ami_name        = local.ami_target_name
  ami_description = "Linux AMI Built with Packer, deployed on ${local.timestamp}"
  region          = "us-east-1"
  instance_type   = "t2.micro"
  ssh_username    = "ec2-user"
  source_ami      = "ami-0e449927258d45bc4"

  tags = {
    "Name"      = local.ami_target_name
    "CreatedBy" = "Packer"

  }

  assume_role {
    role_arn     = "arn:aws:iam::471112829906:role/EC2-Admin-S3FullAccess"
    session_name = "building-linux-ami-with-packer"
  }
}

build {
  name    = "Linux-AMI-Build"
  sources = ["source.amazon-ebs.mylinux"]
  provisioner "shell" {
    script = "basic_setup.sh"
    pause_before = "15s"
  }
}