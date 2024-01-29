module "ecr_build" {
  source            = "./ecr-module"
  ecr_repo_name     = "your-ecr-repo-name"
  dockerfile_path   = "../Dockerfile"  # Path relative to ecr-module directory
}

provider "aws" {
  region = "your-aws-region"
}

resource "aws_ecr_repository" "this" {
  name = var.ecr_repo_name
}

resource "null_resource" "build_push" {
  provisioner "local-exec" {
    command = "./scripts/build_push.sh ${aws_ecr_repository.this.repository_url} ${var.dockerfile_path}"
  }
}

variable "ecr_repo_name" {
  description = "Name for the ECR repository"
  type        = string
}

variable "dockerfile_path" {
  description = "Path to the Dockerfile"
  type        = string
}



#!/bin/bash

ecr_repo_url=$1
dockerfile_path=$2

# Build Docker image
docker build -t $ecr_repo_url $dockerfile_path

# Authenticate Docker to ECR
aws ecr get-login-password --region your-aws-region | docker login --username AWS --password-stdin $ecr_repo_url

# Push Docker image to ECR
docker push $ecr_repo_url


#!/bin/bash

# Extract the Python version constraint from pyproject.toml
version_constraint=$(awk -F'"' '/^python/ {print $2}' pyproject.toml)

# Use the version constraint in your script
echo "Python version constraint: $version_constraint"

# Add your logic here...

