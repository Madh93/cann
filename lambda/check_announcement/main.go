package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

type Announcement struct {
	URL string
	TTL int64
}

var (
	dynamodbTable = os.Getenv("DYNAMODB_TABLE")
	baseURL       = os.Getenv("BASE_URL")
	dateFormat    = os.Getenv("DATE_FORMAT")
	prefix        = os.Getenv("PREFIX")

	url = fmt.Sprintf("%s/%s%s.PDF", baseURL, prefix, time.Now().Format(dateFormat))

	client *dynamodb.Client
)

func exitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func existsTodayAnnouncementInDynamo(ctx context.Context) bool {
	fmt.Printf("Checking if today's announcement exists in %q DynamoDB table...\n", dynamodbTable)

	output, err := client.GetItem(ctx, &dynamodb.GetItemInput{
		TableName: &dynamodbTable,
		Key: map[string]types.AttributeValue{
			"URL": &types.AttributeValueMemberS{
				Value: url,
			},
		},
	})
	if err != nil {
		exitErrorf("Failed to get the item from table %q, %v", dynamodbTable, err)
	}

	if output.Item == nil {
		return false
	}

	return true
}

func existsNewAnnouncement(ctx context.Context) bool {
	fmt.Printf("Checking if today's announcement has been published at: %q\n", url)

	resp, err := http.Get(url)
	if err != nil {
		exitErrorf("unable to get %q, %v", url, err)
	}
	status := resp.StatusCode

	switch status {
	case 200, 404:
		break
	default:
		exitErrorf("unexpected %q status code!", status)
	}

	return status == 200
}

func insertAnnoucementInDynamo(ctx context.Context) error {
	fmt.Println("Inserting today's announcement in DynamoDB...")

	item := Announcement{
		URL: url,
		TTL: time.Now().Add(24 * time.Hour).Unix(),
	}

	attr, err := attributevalue.MarshalMap(item)
	if err != nil {
		return fmt.Errorf("failed to marshal item, %w", err)
	}

	_, err = client.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: &dynamodbTable,
		Item:      attr,
	})
	if err != nil {
		return fmt.Errorf("failed to put item, %w", err)
	}

	fmt.Printf("The announcement was inserted in %q DynamoDB table successfully!\n", dynamodbTable)
	return nil
}

func lambdaHandler(ctx context.Context) error {
	if !existsTodayAnnouncementInDynamo(ctx) {
		if existsNewAnnouncement(ctx) {
			fmt.Println("Today's announcement has been published!")
			return insertAnnoucementInDynamo(ctx)
		} else {
			fmt.Println("No today's announcement yet")
		}
	} else {
		fmt.Println("Today's announcement has already been published. Nothing to do")
	}

	return nil
}

func main() {
	fmt.Println("Initializing...")

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		exitErrorf("cannot load the AWS config: %v", err)
	}

	client = dynamodb.NewFromConfig(cfg)
	fmt.Println("Ready!")

	lambda.Start(lambdaHandler)
}
