#! /bin/bash

LAMBDA_NAME=$1
OUTPUT_DIR=artifacts
GO_MODULE_NAME="gitlab.com/Madh93/cann"
GO_OS_ARCH="linux/amd64"

build() {
  echo "Building..."
  if [ -z "$1" ]; then
    target="./..."
  else
    target="$GO_MODULE_NAME/lambda/$1"
  fi
  mkdir -p $OUTPUT_DIR
  $GOPATH/bin/gox -osarch="$GO_OS_ARCH" -output="$OUTPUT_DIR/{{.Dir}}" $target
  echo "Building... Done!"
}

zip() {
  echo -n "Zipping '$1' lambda..."
  cp $OUTPUT_DIR/$1 main && $GOPATH/bin/deterministic-zip -q $OUTPUT_DIR/$1.zip main && rm main
  echo " Done!"
}

# Install dependencies
go install github.com/mitchellh/gox@v1.0.1
go install github.com/timo-reymann/deterministic-zip@1.2.0

# Package
if [[ -z "$LAMBDA_NAME" ]]; then
  build
  for d in `ls -1 lambda`; do
    zip $d
  done
else
  build $LAMBDA_NAME && zip $LAMBDA_NAME
fi

echo "Done! The packages are available under '$OUTPUT_DIR' directory."
