#!/bin/bash
# ===============================================================
# Matrix Morpheus GRUB Theme Installer
# Repository: https://github.com/Priyank-Adhav/Matrix-GRUB-Theme
# ===============================================================

set -e

THEME_NAME="Matrix"
THEME_DIR="/boot/grub/themes"
GRUB_CFG="/etc/default/grub"
GRUB_FILE="/boot/grub/grub.cfg"

echo ""
echo "==========================="
echo "Matrix GRUB Theme Installer"
echo "==========================="
echo ""

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (use sudo)."
    exit 1
fi

# Ensure theme directory exists 
echo "Checking for theme directory..."
mkdir -p "$THEME_DIR"

# Copy theme files 
echo "Installing theme..."
cp -r "$THEME_NAME" "$THEME_DIR/" || {
    echo "Failed to copy theme files."
    exit 1
}

# (Icons are already correctly named uefi.png and adv_arch.png)

# Configure GRUB to use the new theme 
echo "Updating GRUB configuration..."
if grep -q '^GRUB_THEME=' "$GRUB_CFG"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"|" "$GRUB_CFG"
else
    echo "" >> "$GRUB_CFG"
    echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> "$GRUB_CFG"
fi

# Apply GRUB theme fixes
echo "Applying theme layout fixes..."
sed -i -E 's/^[[:space:]]*item_width = [0-9]+/    item_width = 100/' "$THEME_DIR/$THEME_NAME/theme.txt"
sed -i -E 's/^[[:space:]]*item_padding = [0-9]+/    item_padding = 0/' "$THEME_DIR/$THEME_NAME/theme.txt"

# Regenerate GRUB
echo "Rebuilding GRUB configuration..."
if command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o "$GRUB_FILE" >/dev/null
    echo "GRUB configuration updated successfully."
else
    echo "grub-mkconfig not found. Please update your GRUB manually."
    exit 1
fi

echo ""
echo "Installation complete!"
echo "Reboot to see your new Matrix GRUB theme."
echo ""
