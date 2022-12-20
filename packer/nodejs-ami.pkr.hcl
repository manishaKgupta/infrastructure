packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
source "amazon-ebs" "packer-ami-manisha-node" {
  ami_name      = "packer-ami-manisha-nodejs-application-1"
  source_ami    = "ami-0ada6d94f396377f2"
  instance_type = "t3a.small"
  region        = "us-east-2"
  ssh_username  = "ubuntu"
}
build {
  sources = [
    "source.amazon-ebs.packer-ami-manisha-node"
  ]
  provisioner "shell" {
    script = "./application_dep.sh"
  }
}
