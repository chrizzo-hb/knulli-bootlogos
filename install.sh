#!/bin/bash

# Download generate scripts and set permissions
echo -n "Downloading Scripts..."
curl \
    --silent \
    https://raw.githubusercontent.com/zarquon-42/knulli-led-per-game/refs/heads/main/change-bootlogo.sh \
    --output /opt/change-bootlogo.sh && \
echo " Complete" && \
echo -n "Setting Permissions..." && \
chmod +x /opt/change-bootlogo.sh && \
echo " Complete" && \
echo -n "Making changes permanent..." && \
batocera-save-overlay >/dev/null && \
echo " Complete" && \
echo "" && \
echo "Installation Complete" && \
echo "" && \
echo "
Usage: /opt/change-bootlogo.sh
"