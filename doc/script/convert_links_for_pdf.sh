#!/bin/bash

# Script to replace relative markdown links with GitHub links for PDF generation
# Preserves image links (they render in PDF) and external links

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$1" ]; then
    echo "Usage: $0 <github-release-link> [input-file] [output-file]"
    echo ""
    echo "The release link may point at the repository root or at the input file's"
    echo "own directory; the missing part is derived from where the file sits."
    echo "The output defaults to README_UPDATE.md beside the input file, so the"
    echo "image links it keeps relative still resolve."
    echo ""
    echo "Example:"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.0.0"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.0.0/doc"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.0.0 doc/README.md doc/README_UPDATE.md"
    echo ""
    echo "Without input file, doc/README.md is converted (resolved from the script's location,"
    echo "so the script can be run from any directory). For the root README.md use"
    echo "convert_links_for_pdf_root.sh."
    exit 1
fi

GITHUB_LINK="${1%/}"  # Remove trailing slash if present

# Default: doc/README.md, the full reference (the root README is a short summary). Resolved from the
# script's own location, not the caller's working directory, so the script works from anywhere.
INPUT_FILE="${2:-$SCRIPT_DIR/../README.md}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# The links in the input file are relative to the file, so the base URL has to be
# too. Accept either form -- the repository root (".../blob/<ref>") or the file's
# own directory (".../blob/<ref>/doc") -- and derive whichever half is missing
# from the file's path inside the repository. Passing the root form used to
# rewrite every "./" link one directory too high, silently: doc/README.md's
# "./technical/x.md" became ".../blob/<ref>/technical/x.md", a 404 in the PDF.
INPUT_DIR=$(cd "$(dirname "$INPUT_FILE")" && pwd)
REPO_ROOT=$(git -C "$INPUT_DIR" rev-parse --show-toplevel 2>/dev/null || true)
REL_DIR=""
if [ -n "$REPO_ROOT" ]; then
    REL_DIR="${INPUT_DIR#"$REPO_ROOT"}"
    REL_DIR="${REL_DIR#/}"        # "doc", or "" when the input file is at the root
fi

if [ -n "$REL_DIR" ] && [ "${GITHUB_LINK%/$REL_DIR}" = "$GITHUB_LINK" ]; then
    GITHUB_LINK="$GITHUB_LINK/$REL_DIR"
fi

# Base URL for the parent of the input file's directory, used by Step 0 to
# rewrite "../path" links -- how doc/README.md must reference repository-root
# siblings such as test/ and src/. Empty when the input file is itself at the
# root, where "../" points outside the repository and cannot be expressed.
GITHUB_LINK_PARENT=""
if [ -n "$REL_DIR" ]; then
    GITHUB_LINK_PARENT="${GITHUB_LINK%/*}"
fi

# Default the output to the input file's own directory, not the caller's working
# directory. The conversion leaves image links relative on purpose, so the
# converted file only renders correctly from where the original sits: written
# anywhere else, doc/README.md's "./schema/x.png" points at nothing.
OUTPUT_FILE="${3:-$INPUT_DIR/README_UPDATE.md}"

# Create a temporary file
TMP_FILE=$(mktemp)
cp "$INPUT_FILE" "$TMP_FILE"

# Use a placeholder to avoid sed escaping issues
PLACEHOLDER="__GITHUB_LINK__"
PLACEHOLDER_PARENT="__GITHUB_LINK_PARENT__"

# Step 0: convert parent-relative links [text](../...) before Step 1, which only
# recognizes the "./" form and would leave these relative and dead in the PDF.
if grep -qE '\]\(\.\./[^)]+\)' "$TMP_FILE"; then
    if [ -z "$GITHUB_LINK_PARENT" ]; then
        echo "Error: '$INPUT_FILE' contains '../' links, which point outside the repository from this location." >&2
        echo "Rewrite them as absolute URLs, or generate the PDF from a file in a subdirectory such as doc/." >&2
        rm -f "$TMP_FILE"
        exit 1
    fi
    sed -i -E "s|\[([^]]+)\]\(\.\./([^)]+)\)|[\1]($PLACEHOLDER_PARENT/\2)|g" "$TMP_FILE"
fi

# Step 1: Convert ALL relative links [text](./...) to placeholder
sed -i -E "s|\[([^]]+)\]\(\./([^)]+)\)|[\1]($PLACEHOLDER/\2)|g" "$TMP_FILE"

# Step 2: Restore image links back to relative (images render inline in PDF)
for ext in png jpg jpeg gif svg ico webp bmp tiff; do
    sed -i -E "s|\[([^]]+)\]\($PLACEHOLDER/([^)]+\.$ext)\)|[\1](./\2)|gi" "$TMP_FILE"
    sed -i -E "s|\[([^]]+)\]\($PLACEHOLDER_PARENT/([^)]+\.$ext)\)|[\1](../\2)|gi" "$TMP_FILE"
done

# Step 3: Replace placeholders with actual GitHub links (parent first)
sed -i "s|$PLACEHOLDER_PARENT|$GITHUB_LINK_PARENT|g" "$TMP_FILE"
sed -i "s|$PLACEHOLDER|$GITHUB_LINK|g" "$TMP_FILE"

mv "$TMP_FILE" "$OUTPUT_FILE"

echo "Created '$OUTPUT_FILE' with GitHub links pointing to:"
echo "  $GITHUB_LINK"

# Step 4: check the result (warnings only, the output file is kept). Fenced code blocks are skipped.
# - a converted link whose target does not exist in the local checkout is a dead link in the PDF
#   (it is usually already wrong in the source, e.g. a "../" too many);
# - a relative link that is not an image and was not converted (e.g. written without "./") stays
#   relative and is dead in the PDF.
WARNINGS=0
while IFS= read -r url; do
    target="${url%%#*}"
    # Test the input file's own directory first: the parent URL is a prefix of it.
    if [ "${target#"$GITHUB_LINK"/}" != "$target" ]; then
        local_path="$INPUT_DIR/${target#"$GITHUB_LINK"/}"
    elif [ -n "$GITHUB_LINK_PARENT" ] && [ "${target#"$GITHUB_LINK_PARENT"/}" != "$target" ]; then
        local_path="$(dirname "$INPUT_DIR")/${target#"$GITHUB_LINK_PARENT"/}"
    else
        continue
    fi
    if [ ! -e "$local_path" ]; then
        echo "Warning: converted link has no local target: $url" >&2
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(awk '/^[[:space:]]*```/{code=!code; next} !code' "$OUTPUT_FILE" \
    | grep -oE '\]\([^) ]+' | sed 's/^](//' | grep -F "${GITHUB_LINK%/*}/" | sort -u)

while IFS= read -r url; do
    echo "Warning: relative link not converted (write it as ./path or ../path): $url" >&2
    WARNINGS=$((WARNINGS + 1))
done < <(awk '/^[[:space:]]*```/{code=!code; next} !code' "$OUTPUT_FILE" \
    | grep -oE '\]\([^) ]+' | sed 's/^](//' \
    | grep -vE '^(#|[a-zA-Z][a-zA-Z0-9+.-]*:|\./|\.\./)' \
    | grep -viE '\.(png|jpe?g|gif|svg|ico|webp|bmp|tiff)(#.*)?$' | sort -u)

if [ "$WARNINGS" -gt 0 ]; then
    echo "$WARNINGS link warning(s): check the source file before generating the PDF." >&2
fi
