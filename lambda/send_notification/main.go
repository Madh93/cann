package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/sns"
)

var (
	topicArn = os.Getenv("TOPIC_ARN")

	client *sns.Client
)

func exitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func sendNotification(ctx context.Context, message string) error {
	fmt.Println("Sending notification to SNS...")

	_, err := client.Publish(ctx, &sns.PublishInput{
		Message:  &message,
		TopicArn: &topicArn,
	})

	if err != nil {
		return fmt.Errorf("failed to send the message, %w", err)
	}

	fmt.Println("The notification was sent to SNS successfully!")
	return nil
}

func lambdaHandler(ctx context.Context, dynamodbEvent events.DynamoDBEvent) error {
	for _, record := range dynamodbEvent.Records {
		if record.EventName == "INSERT" {
			fmt.Println("A new message has arrived!")
			if value, ok := record.Change.NewImage["URL"]; ok {
				err := sendNotification(ctx, value.String())
				if err != nil {
					return fmt.Errorf("error sending notification to SNS, %w", err)
				}
			}
		} else {
			fmt.Println("New changes in DynamoDB, but no new message!")
		}
	}

	return nil
}

func main() {
	fmt.Println("Initializing...")

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		exitErrorf("cannot load the AWS config: %v", err)
	}

	client = sns.NewFromConfig(cfg)
	fmt.Println("Ready!")

	lambda.Start(lambdaHandler)
}
