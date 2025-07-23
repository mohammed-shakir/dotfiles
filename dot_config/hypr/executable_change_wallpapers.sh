#!/usr/bin/env bash

WALL_DIR="$HOME/.local/share/hyde-wallpapers"
# Pick one random file
WP="$(find "$WALL_DIR" -type f | shuf -n1)"

# Preload into memory for instant switch (optional)
hyprctl hyprpaper preload "$WP"

# Apply to all outputs (use specific outputs instead of '*' if desired)
hyprctl hyprpaper wallpaper ",$WP"

# Unload unused to free RAM
hyprctl hyprpaper unload unused
