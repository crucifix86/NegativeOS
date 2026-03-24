#!/bin/sh
# NegativeOS — Install Claude Code
# Run this on a live NegativeOS system to get Claude Code up and running
# Then you can use Claude to test and develop NegativeOS from within itself

set -e

echo "[NegativeOS] Installing Claude Code..."

# Ensure Node.js and npm are present
command -v node >/dev/null 2>&1 || apk add --no-cache nodejs npm
command -v git  >/dev/null 2>&1 || apk add --no-cache git
command -v curl >/dev/null 2>&1 || apk add --no-cache curl

# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

echo ""
echo "[NegativeOS] Claude Code installed."
echo ""
echo "To start:"
echo "  claude"
echo ""
echo "You'll be prompted to authenticate with your Anthropic account on first run."
