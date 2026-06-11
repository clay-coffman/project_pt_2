# Canonical's Ubuntu 24.04. The name filter uses "hvm-ssd-gp3" on purpose - the
# older "hvm-ssd" path has no 24.04 images and would match nothing.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "minecraft" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [aws_security_group.minecraft.id]
  key_name                    = aws_key_pair.minecraft.key_name
  associate_public_ip_address = true

  # No iam_instance_profile: Learner Lab won't let us create one, and the
  # SSH + Ansible setup doesn't need it (that's only for SSM).

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = var.project_name
  }
}
