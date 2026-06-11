resource "aws_key_pair" "minecraft" {
  key_name   = "${var.project_name}-key"
  public_key = file(var.ssh_public_key_path)
}
