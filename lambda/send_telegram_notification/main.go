package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

var (
	telegramChatID = os.Getenv("TELEGRAM_CHAT_ID")

	client *ssm.Client
)

type sendDocumentReqBody struct {
	ChatID   string `json:"chat_id"`
	Document string `json:"document"`
}

func exitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func sendTelegramNotification(ctx context.Context, document string) error {
	fmt.Printf("Sending new announcement to %q Telegram channel...\n", telegramChatID)

	// Retrieve Telegram Auth Token
	result, err := client.GetParameter(ctx, &ssm.GetParameterInput{
		Name:           aws.String("/announcements/telegram/token"),
		WithDecryption: true,
	})
	if err != nil {
		return fmt.Errorf("unable to get Telegram Auth Token from SSM, %w", err)
	}

	// Build Telegram request
	url := fmt.Sprintf("https://api.telegram.org/bot%s/sendDocument", *result.Parameter.Value)
	reqBody := &sendDocumentReqBody{
		ChatID:   telegramChatID,
		Document: document,
	}

	reqBytes, err := json.Marshal(reqBody)
	if err != nil {
		return fmt.Errorf("unable to marshal request body json, %w", err)
	}

	// Send notification
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(reqBytes))
	if err != nil {
		return fmt.Errorf("Unable to post %q url, %w", url, err)
	}
	defer resp.Body.Close()

	fmt.Printf("The announcement %q was sent to %q Telegram channel successfully!\n", document, telegramChatID)
	return nil
}

func lambdaHandler(ctx context.Context, snsEvent events.SNSEvent) error {
	for _, record := range snsEvent.Records {
		fmt.Println("A new message has arrived!")
		err := sendTelegramNotification(ctx, record.SNS.Message)
		if err != nil {
			return fmt.Errorf("error sending notification to Telegram, %w", err)
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

	client = ssm.NewFromConfig(cfg)
	fmt.Println("Ready!")

	lambda.Start(lambdaHandler)
}
