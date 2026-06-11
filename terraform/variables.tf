variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "project_name" {
  type    = string
  default = "cs312-minecraft"
}

# Who's allowed to reach SSH (port 22). Ansible needs this to configure the box.
# Defaults to anywhere because the GitHub Actions runner has no fixed IP. For a
# local-only run, set this to "YOUR.IP/32" in terraform.tfvars.
variable "ssh_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ssh_public_key_path" {
  type    = string
  default = "../keys/minecraft-key.pub"
}

variable "ssh_private_key_path" {
  type    = string
  default = "../keys/minecraft-key"
}
