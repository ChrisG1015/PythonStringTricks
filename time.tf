variable "current_time" {}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "date '+%Y-%m-%d-%H:%M' > current_time.txt"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

output "current_time" {
  value = var.current_time
}
