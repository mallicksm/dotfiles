#!/bin/bash
set -e

# Set target RPM URL and filename
URL="https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/x/xclip-0.13-8.el8.x86_64.rpm"
RPM_FILE="xclip-0.13-8.el8.x86_64.rpm"
EXTRACT_DIR="~/build-xclip"

# Create extract directory if it doesn't exist
mkdir -p "$EXTRACT_DIR" && pushd "$EXTRACT_DIR"

# Download the RPM
echo "📥 Downloading $RPM_FILE..."
curl -LO "$URL"

# Extract binary non-root
echo "📦 Extracting $RPM_FILE to $EXTRACT_DIR..."
rpm2cpio "$RPM_FILE" | cpio -idmv

# Move xclip binary to target dir
if [ -f "./usr/bin/xclip" ]; then
   echo "✅ xclip extracted to ./usr/bin/xclip"
else
   echo "❌ Failed to extract xclip"
   exit 1
fi
popd

# Optional: Show usage
echo -e "\nTo use xclip:"
echo "   cp ./usr/bin/xclip ~/.local/bin/"
echo "   xclip -selection clipboard <<< \"hello world\""

