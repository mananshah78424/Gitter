// Main terraform file 


// Variables
variable "github_token" {
    description = "Github token"
    type = string
    sensitive = true
}

variable "github_owner" {
    description = "Github owner"
    type = string
}

variable "github_repo" {
    description = "Github repo"
    type = string
}

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

    environment {
        variables = {
            GITHUB_TOKEN = var.github_token
            GITHUB_OWNER = var.github_owner
            GITHUB_REPO = var.github_repo
        }
    }

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

// Create the cron schedule
resource "aws_cloudwatch_event_rule" "gitter_schedule" {
    name = "gitter_schedule"
    description = "Schedule to run the lambda function"
    schedule_expression = "cron(20 18 * * ? *)" // Run the lambda function at 6:20 PM UTC
}

// aws_cloudwatch_event_target specifies the Lambda function to be triggered by the CloudWatch event rule.
resource "aws_cloudwatch_event_target" "gitter_lambda_target" {
    rule = aws_cloudwatch_event_rule.gitter_schedule.name
    target_id = "gitter_lambda_target"
    arn = aws_lambda_function.gitter.arn
}

// aws_lambda_permission grants the CloudWatch event rule permission to invoke the Lambda function.

resource "aws_lambda_permission" "name" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.gitter.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.gitter_schedule.arn
}