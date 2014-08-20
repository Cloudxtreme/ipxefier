#!/usr/bin/env bash

# Run > mfsbsd image. dd mfsbsd image to usb stick. Boot box with stick.

ACCOUNT=${1:-default}
IMAGE=f0b8595d-128e-4514-a5cc-847429dcfa6b
FLAVOR=performance1-8

DIR="`dirname $(readlink -f $0)`"

baker.sh $ACCOUNT $IMAGE $FLAVOR "$DIR/base.sh $DIR/include/*"
