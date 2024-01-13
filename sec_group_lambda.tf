variable "sec_group_name" {
  description = "Name of the security group"
}

variable "ports" {
  description = "Map of ports to create security groups"
}

resource "aws_security_group" "dynamic_sec_group" {
  count        = length(keys(var.ports))
  name         = "${var.sec_group_name}-${element(keys(var.ports), count.index)}"
  description  = "Dynamic Security Group for ${element(keys(var.ports), count.index)}"
  
  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port = ingress.value
      to_port   = ingress.value
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "sec_group_ids" {
  value = aws_security_group.dynamic_sec_group[*].id
}




provider "aws" {
  region = "us-east-1"  # Update with your desired region
}

module "cyberdynamic_api" {
  source = "./modules/cyberdynamic_api"
  
  sec_group_name = "cyberdynamic"
  ports = {
    "https" = 443,
    "rdp"   = 3389
    # Add more ports as needed
  }
}

# Save security group IDs to a YAML file
locals {
  security_group_ids = {
    "https-cyberdynamic-api" = {
      ports         = [443],
      sec_group_id  = module.cyberdynamic_api.sec_group_ids[0]  # Assuming https is the first port
    },
    "rdp-cyberdynamic-api" = {
      ports         = [3389],
      sec_group_id  = module.cyberdynamic_api.sec_group_ids[1]  # Assuming rdp is the second port
    },
    # Add more entries for other ports
  }
}

resource "local_file" "yaml_file" {
  content  = yamlencode(local.security_group_ids)
  filename = "security_groups.yaml"
}

# Create an S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "your-s3-bucket-name"  # Update with your desired bucket name
  acl    = "private"
}

# Upload the YAML file to S3
resource "aws_s3_bucket_object" "yaml_object" {
  bucket = aws_s3_bucket.example_bucket.bucket
  key    = "security_groups.yaml"
  source = local_file.yaml_file.filename
}
