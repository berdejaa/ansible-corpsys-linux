source "amazon-ebs" "globoticket" {
  ssh_username  = "ubuntu"
  ami_name      = "globoticket-${uuidv4()}"
  source_ami    = "ami-0efcece6bed30fd98"
  instance_type = "t3.micro"

}

build {
  sources = ["source.amazon-ebs.globoticket"]
}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}
