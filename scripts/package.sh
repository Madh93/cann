#! /bin/bash

LAMBDA_NAME=$1

build_and_zip() {
    echo "Packaging '$1' lambda..."
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build lambda/$1/main.go && .bin/deterministic-zip -q artifacts/$1.zip main && rm main
}

# Install dependencies
mkdir -p artifacts .bin
if [ ! -f ".bin/deterministic-zip" ]; then
  curl -o .bin/deterministic-zip -sSLO https://github.com/timo-reymann/deterministic-zip/releases/download/$(curl -Lso /dev/null -w %{url_effective} https://github.com/timo-reymann/deterministic-zip/releases/latest | grep -o '[^/]*$')/deterministic-zip_linux-amd64
  chmod +x .bin/deterministic-zip
fi

# Package
if [[ -z "$LAMBDA_NAME" ]]; then
    for d in `ls -1 lambda`; do
        build_and_zip $d
    done
else
    build_and_zip $LAMBDA_NAME
fi

echo "Done! The packages are available under 'artifacts' directory."
