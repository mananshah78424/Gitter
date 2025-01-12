// Description: This is the main file that contains the code for the Lambda function.
package main

import (
	"context"
	"log"

	"github.com/aws/aws-lambda-go/lambda"
)

func pushGithubCommit(ctx context.Context) (string, error) {
	log.Println("Pushing commit to Github")
	return "Commit pushed to Github", nil
}

func main() {
	lambda.Start(pushGithubCommit)
}
