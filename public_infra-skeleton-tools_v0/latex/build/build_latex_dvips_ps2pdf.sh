#!/bin/bash

# Set file name without extension
FILE="${1%.*}"
OUT_DIR="./out"

# Check if the output directory exists; if not, create it with appropriate permissions
if [ ! -d "$OUT_DIR" ]; then
    mkdir -p "$OUT_DIR"
    chmod 755 "$OUT_DIR"
    echo "Output directory $OUT_DIR created with correct permissions."
fi

# Step 1: Compile LaTeX to DVI
latex -interaction=nonstopmode -output-directory="$OUT_DIR" "$FILE.tex"

# Step 2: Run Biber (or BibTeX, depending on the system)
if [ -f "$OUT_DIR/$FILE.bcf" ]; then
    biber "$OUT_DIR/$FILE"
elif [ -f "$OUT_DIR/$FILE.aux" ]; then
    bibtex "$OUT_DIR/$FILE"
fi

# Step 3: Compile LaTeX to DVI again to update references
latex -interaction=nonstopmode -output-directory="$OUT_DIR" "$FILE.tex"

# Step 4: Convert DVI to PS
dvips "$OUT_DIR/$FILE.dvi" -o "$OUT_DIR/$FILE.ps"

# Step 5: Convert PS to PDF
ps2pdf "$OUT_DIR/$FILE.ps" "$OUT_DIR/$FILE.pdf"

# Ensure correct permissions for all files in the output directory
chmod -R 644 "$OUT_DIR"/*
chmod 755 "$OUT_DIR"

# Confirm completion
if [ -f "$OUT_DIR/$FILE.pdf" ]; then
    echo "PDF successfully generated at $OUT_DIR/$FILE.pdf with correct permissions."
else
    echo "Error: PDF was not generated."
fi
