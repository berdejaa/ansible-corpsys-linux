data "amazon-ami" "amzn2-corpsys" {
  filters = {
    virtualization-type = "hvm"
    name                = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
}

data "amazon-ami" "amzn2023-corpsys" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-2023.2*-x86_64"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
}

packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "amzn2-corpsys" {
  vpc_id               = "vpc-2875b44d"
  subnet_id            = "subnet-9107d8f4"
  region               = "us-west-2"
  ssh_username         = "ec2-user"
  ssh_keypair_name     = "bbcom_general_key"
  ssh_private_key_file = "/Users/arthur.berdeja/.ssh/bbcom_general.pem"
  ami_name             = "amzn2-corpsys-${uuidv4()}"
  source_ami           = data.amazon-ami.amzn2-corpsys.id
  instance_type        = "t3.micro"
  tags = {
    OS_Version    = "Amazon Linux 2"
    Name          = "Amazon Linux 2 Corpsys Base"
    Release       = "Latest"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
  }
}

source "amazon-ebs" "amzn2023-corpsys" {
  vpc_id               = "vpc-2875b44d"
  subnet_id            = "subnet-9107d8f4"
  region               = "us-west-2"
  ssh_username         = "ec2-user"
  ssh_keypair_name     = "bbcom_general_key"
  ssh_private_key_file = "/Users/arthur.berdeja/.ssh/bbcom_general.pem"
  ami_name             = "amzn2023-corpsys-${uuidv4()}"
  source_ami           = data.amazon-ami.amzn2023-corpsys.id
  instance_type        = "t3.micro"
  tags = {
    OS_Version    = "Amazon Linux 2023"
    Name          = "Amazon Linux 2023 Corpsys Base"
    Release       = "Latest"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Extra         = "{{ .SourceAMITags.TagName }}"
  }
}

build {
  sources = [
    "source.amazon-ebs.amzn2-corpsys",
    "source.amazon-ebs.amzn2023-corpsys"
  ]

  provisioner "shell" {
    execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
    inline = [
      "echo 'Defaults !requiretty' >>/etc/sudoers",
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_packages.yml"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
    inline = [
      "amazon-linux-extras install epel -y",
      "yum install -y nc ngrep redhate-lsb-core curl"
    ]
    only = ["amazon-ebs.amzn2-corpsys"]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_users.yml"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_autofs.yml"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_ntp.yml"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_sysctl.yml"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible-corpsys_auth.yml"
    user          = "ec2-user"
    extra_arguments = [
      "--scp-extra-args",
      "'-O'"
    ]
  }

  provisioner "shell" {
    execute_command = "sudo -S env {{ .Vars }} {{ .Path }}"
    inline = [
      "sed -i 's|.ssh/authorized_keys|/etc/ssh/users/%u.pub|' /etc/ssh/sshd_config",
      "echo 'match User ec2-user' >>/etc/ssh/sshd_config",
      "echo '    AuthorizedKeysFile .ssh/authorized_keys' >>/etc/ssh/sshd_config",
      "systemctl restart sshd.service"
    ]
  }
}

