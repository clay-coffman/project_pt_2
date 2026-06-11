# Write the new instance's IP straight into the Ansible inventory so we never
# copy-paste it by hand.
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    public_ip = aws_instance.minecraft.public_ip
    key_path  = abspath("${path.module}/${var.ssh_private_key_path}")
  })
}
