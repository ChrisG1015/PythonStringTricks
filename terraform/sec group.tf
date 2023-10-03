resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Example security group"

  # Ingress rule to allow incoming SSH (port 22) traffic from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your desired IP range
  }
}
In this configuration, we've defined an AWS security group (aws_security_group) named "example-sg" that allows incoming SSH traffic (port 22) from any IP address (0.0.0.0/0). You can customize the from_port, to_port, and cidr_blocks as needed.

Key Pair Configuration (main.tf):
hcl
Copy code
resource "aws_key_pair" "example_keypair" {
  key_name   = "example-keypair"
  public_key = file("~/.ssh/id_rsa.pub") # Replace with your own public key path
}
In this configuration, we've created an AWS key pair (aws_key_pair) named "example-keypair." The public_key attribute is set to the path of your public SSH key (e.g., ~/.ssh/id_rsa.pub). Ensure that you replace this path with the actual path to your SSH public key file.

These configurations can be added to your existing Terraform project alongside the other resources mentioned in the original Terraform question. After defining these resources, run terraform init and terraform apply to apply the changes and create the security group and key pair resources.




