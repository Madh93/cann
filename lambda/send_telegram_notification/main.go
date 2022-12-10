package main

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api/v5"
	"gitlab.com/Madh93/cann/internal/utils"
)

var (
	client         *ssm.Client
	announcementID string

	// Telegram config
	authToken   string
	chatID      int64
	channelName string
)

func loadSSMParameters(ctx context.Context) (err error) {
	// Retrieve Telegram Auth Token
	authToken, err = utils.GetSSMParameterValue(client, ctx, os.Getenv("SSM_TELEGRAM_AUTH_TOKEN"))
	if err != nil {
		return fmt.Errorf("unable to get Telegram Auth Token from SSM, %w", err)
	}

	// Retrieve all parameters at once
	parameters, err := utils.GetSSMParameters(client, ctx, fmt.Sprintf("/announcements/telegram/%s", announcementID))
	if err != nil {
		return fmt.Errorf("unable to get parameters from SSM, %w", err)
	}

	// Set Chat ID
	channelIDTemplate, _ := utils.ParseSSMParemeterTemplate(os.Getenv("SSM_TELEGRAM_CHAT_ID"), announcementID)
	chatIDStr, err := utils.GetSSMParameterValueFrom(parameters, channelIDTemplate)
	if err != nil {
		return fmt.Errorf("unable to get Telegram Chat ID from SSM, %w", err)
	}
	chatID, _ = strconv.ParseInt(chatIDStr, 10, 64)

	// Set Channel Name
	channelNameTemplate, _ := utils.ParseSSMParemeterTemplate(os.Getenv("SSM_TELEGRAM_CHANNEL_NAME"), announcementID)
	channelName, err = utils.GetSSMParameterValueFrom(parameters, channelNameTemplate)
	if err != nil {
		return fmt.Errorf("unable to get Telegram Channel Name from SSM, %w", err)
	}

	return
}

func sendTelegramNotification(ctx context.Context, url string) error {
	fmt.Printf("Sending new announcement to %q Telegram channel...\n", channelName)

	// Download file
	filename, err := utils.DownloadFile(url)
	if err != nil {
		return fmt.Errorf("error downloading file, %w", err)
	}

	// Initialize bot
	bot, err := tgbotapi.NewBotAPI(authToken)
	if err != nil {
		return fmt.Errorf("unable to initialize Telegram Bot, %w", err)
	}

	// Send notification
	msg := tgbotapi.NewDocument(chatID, tgbotapi.FilePath(filename))
	_, err = bot.Send(msg)
	if err != nil {
		return fmt.Errorf("unable to send document %w", err)
	}

	fmt.Printf("The announcement %q was sent to %q Telegram channel successfully!\n", url, channelName)
	return nil
}

func lambdaHandler(ctx context.Context, snsEvent events.SNSEvent) error {
	for _, record := range snsEvent.Records {
		fmt.Println("A new message has arrived!")

		// Setup SSM Parameters
		url := record.SNS.Message
		announcementID = utils.GetAnnouncementID(url)
		err := loadSSMParameters(ctx)
		if err != nil {
			return fmt.Errorf("failed to load SSM Parameters, %v", err)
		}

		// Send notification
		err = sendTelegramNotification(ctx, url)
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
		utils.ExitWithError("cannot load the AWS config: %v", err)
	}

	client = ssm.NewFromConfig(cfg)
	fmt.Println("Ready!")

	lambda.Start(lambdaHandler)
}
