#!/bin/bash
if [ ! -d "./app/tweepy" ]; then
    pip install tweepy==4.14.0 -t ./app/
    rm -rf ./app/urllib3*
    pip install urllib3==1.26.7 -t ./app/
else
    echo "Tweepy already installed."
fi