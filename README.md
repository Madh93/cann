# cann

Serverless app to check the daily [substitute teachers announcements](https://www.gobiernodecanarias.org/educacion/web/personal/docente/oferta/interinos-sustitutos/nombramientos_diarios/) of Government of the Canary Islands. When a new announcement is published, a notification is sent to Telegram.

## Requirements

- [Go](https://golang.org) 1.19
- [Terraform](https://www.terraform.io) 1.0.0

## Architecture

![Diagram](docs/img/cann-architecture.png)

## How it works

A scheduled event executed at regular intervals triggers a Lambda function that
checks if there is a new announcement. When a new announcement is published, the
URL is stored in a DynamoDB table that triggers a second lambda which publish in a
SNS Topic. Finally a Lambda subscribed to the topic notifies to a Telegram channel.

- **CloudWatch Events:** cron scheduled triggers
- **DynamoDB:** store the state
- **SNS:** fan-out notifications
- **Parameter Store:** Telegram auth token
- **Lambdas:**
  - [check_announcement](lambda/check_announcement/main.go)
  - [send_notification](lambda/send_notification/main.go)
  - [send_telegram_notification](lambda/send_telegram_notification/main.go)


## Motivation

This is just a pet project to play with Go, Terraform and Serverless architecture. This solution can be replaced by a [simple bash script](https://github.com/Madh93/dockerfiles/blob/master/nombramiento-maestros/nombramiento-maestros.sh) executed by a cron job running on a server 24/7, however the biggest attractive of this solution it is an almost zero cost solution thanks to the [AWS Free Tier](https://aws.amazon.com/free).

## Current integrations

| Name | Telegram |
|---|---|
| Maestros de S/C Tenerife | https://t.me/nombramientos_maestros_tfe |
| Maestros de Las Palmas | https://t.me/nombramientos_maestros_lp |
| Profesores de ambas | https://t.me/nombramientos_profesores |
