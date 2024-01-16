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
      sed -i 's/\(https:-cyberdynamic-api:.*ports: 443.*\)sec_group_id: /\\1sec_group_id: ${aws_security_group.cyberdynamic.id}/' your_yaml_file.yaml
      sed -i 's/\(rdp-cyberdynamic-api:.*ports: 3389.*\)sec_group_id: /\\1sec_group_id: ${aws_security_group.cyberdynamic.id}/' your_yaml_file.yaml
    EOT
  }
}


provisioner "local-exec" {
    command = <<-EOT
      for port in "${join(" ", values(var.cyberdynamic_ports))}"; do
        sed -i "s/\(${port}-cyberdynamic-api:.*ports: ${port}.*\)sec_group_id: /\\1sec_group_id: ${aws_security_group.cyberdynamic.id}/" your_yaml_file.yaml
      done
    EOT
  }
