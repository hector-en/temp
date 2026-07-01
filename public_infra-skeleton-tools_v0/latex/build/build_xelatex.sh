#!/bin/bash
# Compile with xelatex and biber for bibliography

if [ -z "$1" ]; then
  echo "No file provided."
  exit 1
fi

filename="$1"

xelatex -interaction=nonstopmode -synctex=1 "$filename"
biber "${filename%.*}"
xelatex -interaction=nonstopmode -synctex=1 "$filename"

