variable "cyberdynamic_ports" {
  type    = map(number)
  default = {
    https = 443
    rdp   = 3389
  }
}

resource "aws_security_group" "cyberdynamic" {
  name        = "cyberdynamic-security-group"
  description = "Security group for CyberDynamic API"

  dynamic "ingress" {
    for_each = var.cyberdynamic_ports

    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"

      # You can customize tags here if needed
      tags = {
        Name = "${ingress.key}-security-group-rule"
      }
    }
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "https:-cyberdynamic-api:" >> your_yaml_file.yaml
      echo "  ports: ${var.cyberdynamic_ports["https"]}" >> your_yaml_file.yaml
      echo "  sec_group_id: ${aws_security_group.cyberdynamic.id}" >> your_yaml_file.yaml

      echo "rdp-cyberdynamic-api:" >> your_yaml_file.yaml
      echo "  ports: ${var.cyberdynamic_ports["rdp"]}" >> your_yaml_file.yaml
      echo "  sec_group_id: ${aws_security_group.cyberdynamic.id}" >> your_yaml_file.yaml
    EOT
  }
}
