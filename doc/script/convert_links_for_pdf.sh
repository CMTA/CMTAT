#!/bin/bash

# Script to replace relative markdown links with GitHub links for PDF generation
# Preserves image links (they render in PDF) and external links

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <github-release-link> [input-file] [output-file]"
    echo ""
    echo "Example:"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.0.0"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.0.0 README.md README_UPDATE.md"
    exit 1
fi

GITHUB_LINK="${1%/}"  # Remove trailing slash if present
INPUT_FILE="${2:-../../README.md}"
OUTPUT_FILE="${3:-README_UPDATE.md}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Create a temporary file
TMP_FILE=$(mktemp)
cp "$INPUT_FILE" "$TMP_FILE"

# Use a placeholder to avoid sed escaping issues
PLACEHOLDER="__GITHUB_LINK__"

# Step 1: Convert ALL relative links [text](./...) to placeholder
sed -i -E "s|\[([^]]+)\]\(\./([^)]+)\)|[\1]($PLACEHOLDER/\2)|g" "$TMP_FILE"

# Step 2: Restore image links back to relative (images render inline in PDF)
for ext in png jpg jpeg gif svg ico webp bmp tiff; do
    sed -i -E "s|\[([^]]+)\]\($PLACEHOLDER/([^)]+\.$ext)\)|[\1](./\2)|gi" "$TMP_FILE"
done

# Step 3: Replace placeholder with actual GitHub link
sed -i "s|$PLACEHOLDER|$GITHUB_LINK|g" "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

echo "Created '$OUTPUT_FILE' with GitHub links pointing to:"
echo "  $GITHUB_LINK"
