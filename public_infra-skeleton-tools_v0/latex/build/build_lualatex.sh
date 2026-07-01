#!/bin/bash

# Check if the output directory exists, if not, create it and set permissions
if [ ! -d "./out" ]; then
  mkdir -p ./out
  chmod u+w ./out
  echo "Output directory ./out created and permissions set."
fi

# Step 1: Run lualatex
lualatex -interaction=nonstopmode -synctex=1 -output-directory=./out "$1"

# Step 2: Run biber (without file extension)
biber "./out/$(basename "$1" .tex)"

# Step 3: Run lualatex again
lualatex -interaction=nonstopmode -synctex=1 -output-directory=./out "$1"

echo "Build completed with lualatex."

