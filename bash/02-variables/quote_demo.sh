#!/usr/bin/env bash

NAME="Wojtek Furman"
FILES="*"

echo "=============================="
echo "Quoting examples"
echo "=============================="

echo
echo "No quotes:"
echo $NAME

echo
echo "Double quotes:"
echo "$NAME"

echo
echo "Single quotes:"
echo '$NAME'

echo
echo "=============================="
echo "Wildcard examples"
echo "=============================="

echo
echo "No quotes:"
echo $FILES

echo
echo "Double quotes:"
echo "$FILES"

echo
echo "Single quotes:"
echo '$FILES'

echo
echo "=============================="
echo "Command-line arguments"
echo "=============================="

echo "First argument: $1"
echo "Second argument: $2"

echo
echo "=============================="
echo "Interactive input"
echo "=============================="

read -r -p "Enter your name: " USER_NAME
read -r -p "Enter your favourite technology: " USER_TECHNOLOGY

echo
echo "Name from argument: $1"
echo "Technology from argument: $2"

echo
echo "Name from read: $USER_NAME"
echo "Technology from read: $USER_TECHNOLOGY"
