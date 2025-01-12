// Main terraform file 
terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    }
}

# Configure the AWS Provider
provider "aws" {
    region = "us-west-2"
}

# Create lambda function 
resource "aws_lambda_function" "gitter" {
  function_name = "gitter"
    filename      = "gitter.zip"
    role = aws_iam_role.gitter_lambda_role.arn
    package_type = "Zip"
    runtime = "provided.al2"
    handler = "bootstrap"
    
    source_code_hash = filebase64sha256("gitter.zip")

    depends_on = [aws_iam_role.gitter_lambda_role] 

    tags = {
      Name ="Daily commiter for github"
    }

}

# Create IAM role for lambda function

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
  
locals {
    account_id = data.aws_caller_identity.current.account_id
    region = data.aws_region.current.name
}

resource "aws_iam_role" "gitter_lambda_role" {
    name="gitter_lambda_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "lambda.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })  
}

resource "aws_iam_role_policy" "gitter_lambda_role_policy" {
    name = "gitter_lambda_role_policy"
    role = aws_iam_role.gitter_lambda_role.id

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Action = "*",
                Resource = "*"
            }
        ]
    })
  
}