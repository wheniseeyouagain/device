#!/bin/bash -e
#
# Post-build hook to install device tree overlays to rootfs
#
# This script copies ubootEnv.txt and overlays/ to /boot on the target rootfs.
# The dynamic overlay loader in U-Boot will read these files at boot time.
#
# Copyright (C) 2024-2025 TaishanPi Team
# SPDX-License-Identifier: GPL-2.0+

source "${RK_POST_HELPER:-$(dirname "$(realpath "$0")")/post-helper}"

# Only process for rootfs
[ "$POST_ROOTFS" ] || exit 0

OVERLAY_SRC="$RK_OUTDIR/overlays"
OVERLAY_DEST="$TARGET_DIR/boot"

# Check if overlay files exist
if [ ! -d "$OVERLAY_SRC" ]; then
	message "No overlay files found in $OVERLAY_SRC, skipping..."
	exit 0
fi

message "Installing device tree overlays to rootfs..."

# Create destination directories
mkdir -p "$OVERLAY_DEST/overlays"

# Copy ubootEnv.txt
if [ -f "$OVERLAY_SRC/ubootEnv.txt" ]; then
	notice "Installing ubootEnv.txt..."
	cp "$OVERLAY_SRC/ubootEnv.txt" "$OVERLAY_DEST/"
fi

# Copy overlay .dtbo files
if ls "$OVERLAY_SRC/overlays/"*.dtbo 1>/dev/null 2>&1; then
	DTBO_COUNT=$(ls -1 "$OVERLAY_SRC/overlays/"*.dtbo | wc -l)
	notice "Installing $DTBO_COUNT overlay file(s)..."
	cp "$OVERLAY_SRC/overlays/"*.dtbo "$OVERLAY_DEST/overlays/"
fi

message "Device tree overlays installed to $OVERLAY_DEST"

# Print summary
echo ""
echo "Overlay Installation Summary:"
echo "  Configuration: $OVERLAY_DEST/ubootEnv.txt"
echo "  Overlays:      $OVERLAY_DEST/overlays/"
if ls "$OVERLAY_DEST/overlays/"*.dtbo 1>/dev/null 2>&1; then
	for dtbo in "$OVERLAY_DEST/overlays/"*.dtbo; do
		echo "                 - $(basename "$dtbo")"
	done
fi
echo ""
