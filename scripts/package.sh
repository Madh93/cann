#! /bin/bash

LAMBDA_NAME=$1

build_and_zip() {
    echo "Packaging '$1' lambda..."
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build lambda/$1/main.go && touch --date=@0 main && zip -rq artifacts/$1.zip main && rm main
}

mkdir -p artifacts

if [[ -z "$LAMBDA_NAME" ]]; then
    for d in `ls -1 lambda`; do
        build_and_zip $d
    done
else
    build_and_zip $LAMBDA_NAME
fi

echo "Done! The packages are available under 'artifacts' directory."
