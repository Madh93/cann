package main

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
)

var (
	telegramChatID, _ = strconv.ParseInt(os.Getenv("TELEGRAM_CHAT_ID"), 10, 64)
	telegramChatName  = os.Getenv("TELEGRAM_CHAT_NAME")

	client *ssm.Client
)

func exitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

func sendTelegramNotification(ctx context.Context, document string) error {
	fmt.Printf("Sending new announcement to %q Telegram channel...\n", telegramChatName)

	// Retrieve Telegram Auth Token
	result, err := client.GetParameter(ctx, &ssm.GetParameterInput{
		Name:           aws.String("/announcements/telegram/token"),
		WithDecryption: true,
	})
	if err != nil {
		return fmt.Errorf("unable to get Telegram Auth Token from SSM, %w", err)
	}

	// Initialize bot
	bot, err := tgbotapi.NewBotAPI(*result.Parameter.Value)
	if err != nil {
		return fmt.Errorf("unable to initialize Telegram Bot, %w", err)
	}

	// Send notification
	msg := tgbotapi.NewDocument(telegramChatID, tgbotapi.FilePath(document))
	_, err = bot.Send(msg)
	if err != nil {
		return fmt.Errorf("unable to send document %w", err)
	}

	fmt.Printf("The announcement %q was sent to %q Telegram channel successfully!\n", document, telegramChatName)
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
