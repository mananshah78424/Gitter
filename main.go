// Description: This is the main file that contains the code for the Lambda function.
package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/google/go-github/v45/github"
	"golang.org/x/oauth2"
)

func pushGithubCommit(ctx context.Context) (string, error) {
	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		return "", fmt.Errorf("GITHUB_TOKEN environment variable is not set")
	}
	owner := os.Getenv("GITHUB_OWNER")
	repo := os.Getenv("GITHUB_REPO")

	// Create GitHub client
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	currentDate := time.Now().Format("2006-01-02")
	log.Printf("Updating date.txt with date: %s", currentDate)
	fileContent, _, _, err := client.Repositories.GetContents(ctx, owner, repo, "date.txt", nil)
	if err != nil && err.(*github.ErrorResponse).Response.StatusCode != 404 {
		return "", fmt.Errorf("error getting file content: %v", err)
	}

	// Create or update the file content
	content := []byte(fmt.Sprintf("Last updated: %s", currentDate))
	var sha *string
	if fileContent != nil {
		sha = fileContent.SHA
	}

	// create the commit
	commitMessage := fmt.Sprintf("Update date.txt with date: %s", currentDate)
	opts := &github.RepositoryContentFileOptions{
		Message: &commitMessage,
		Content: content,
		SHA:     sha,
	}

	// push the commit
	_, _, err = client.Repositories.UpdateFile(ctx, owner, repo, "date.txt", opts)
	if err != nil {
		return "", fmt.Errorf("error updating file: %v", err)
	}

	return fmt.Sprintf("Successfully updated date to %s", currentDate), nil
}

func main() {
	lambda.Start(pushGithubCommit)
}
