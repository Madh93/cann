# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build -race
GORUN=$(GOCMD) run
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test

.PHONY: all test clean

all: build
clean:
	$(GOCLEAN) && rm -rf artifacts main
test:
	$(GOTEST) ||: # TODO: Remove me when tests will be added
run:
	$(GORUN) lambda/$(lambda)/main.go
build:
	for d in $$(ls -1 lambda); do echo "Building '$$d' lambda..." && $(GOBUILD) lambda/$$d/main.go && rm main; done
package:
	scripts/package.sh $(lambda)
update-dependencies:
	go get -u all && go mod tidy
