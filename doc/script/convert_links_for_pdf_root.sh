#!/bin/bash

# Same conversion as convert_links_for_pdf.sh, applied to the root README.md
# (the short summary) instead of doc/README.md (the full reference).
#
# It differs only in its default input, so it delegates rather than duplicating:
#   - input : the repository's root README.md
# The output follows the input's directory, which the other script already does,
# so it needs no default here. Link rewriting, image handling and the base-URL
# derivation all stay there too; change behaviour there and both entry points
# follow.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONVERT="$SCRIPT_DIR/convert_links_for_pdf.sh"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || (cd "$SCRIPT_DIR/../.." && pwd))"

if [ -z "$1" ]; then
    echo "Usage: $0 <github-release-link> [input-file] [output-file]"
    echo ""
    echo "Converts the root README.md. For doc/README.md use convert_links_for_pdf.sh."
    echo ""
    echo "Example:"
    echo "  $0 https://github.com/CMTA/CMTAT/blob/v3.3.0"
    exit 1
fi

if [ ! -x "$CONVERT" ]; then
    echo "Error: '$CONVERT' not found or not executable"
    exit 1
fi

exec "$CONVERT" "$1" "${2:-$REPO_ROOT/README.md}" "${3:-}"
