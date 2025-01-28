## What is Gitter?

Gitter is a tool that helps maintain your daily contribution on Github. Using a cron job, it pushes ~~2~~ 1 daily ~~commits~~  commit on to your GitHub repo, thus helping you maintain your daily contributions.

## Tools Used

1. AWS Cron Job
2. AWS CloudWatch
3. AWS Lamdba 
4. Terraform 
5. Golang
6. Github

## Logic

Looks at the current date. Updates `date.txt` file with the current date. It then generates a commit message and pushes the code to the repo. Cloudwatch (`gitter_schedule`) will trigger the Lambda function (`gitter`) at 6PM UTC. IAM rule used is - `gitter_lambda_role`  and `gitter_lambda_role_policy` .

## Notes

Preparing a binary to deploy to AWS Lambda requires that it is compiled for Linux and placed into a .zip file. When using the `provided`, `provided.al2`, or `provided.al2023` runtime, the executable within the .zip file should be named `bootstrap`.
