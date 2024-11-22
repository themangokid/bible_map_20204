#!/bin/bash

# Directory to save tiles
TILE_DIR="assets/tiles"
mkdir -p $TILE_DIR
USER_AGENT="BiblicalJourneyApp (your.email@example.com)"

# Function to calculate tile X/Y coordinates for a given latitude, longitude, and zoom level
latlon_to_tile() {
    local lat=$1
    local lon=$2
    local zoom=$3

    local n=$(echo "2^$zoom" | bc)
    local xtile=$(echo "($lon + 180) / 360 * $n" | bc -l | awk '{print int($1)}')
    local lat_rad=$(echo "$lat * 3.141592653589793 / 180" | bc -l)
    local ytile=$(echo "(1 - l( tan($lat_rad) + 1 / cos($lat_rad)) / 3.141592653589793) / 2 * $n" | bc -l | awk '{print int($1)}')

    echo "$xtile $ytile"
}

# Function to download tiles for a specific bounding box and zoom range
download_tiles() {
    local lat_min=$1
    local lat_max=$2
    local lon_min=$3
    local lon_max=$4
    local zoom_min=$5
    local zoom_max=$6

    for zoom in $(seq $zoom_min $zoom_max); do
        read x_min y_max <<< $(latlon_to_tile $lat_max $lon_min $zoom)
        read x_max y_min <<< $(latlon_to_tile $lat_min $lon_max $zoom)

        echo "Zoom level $zoom: X range = $x_min to $x_max, Y range = $y_min to $y_max"

        for x in $(seq $x_min $x_max); do
            for y in $(seq $y_min $y_max); do
                TILE_URL="https://a.tile.openstreetmap.org/$zoom/$x/$y.png"
                TILE_PATH="$TILE_DIR/$zoom/$x/$y.png"

                mkdir -p "$(dirname $TILE_PATH)"
                wget -q --show-progress --header="User-Agent: $USER_AGENT" -O $TILE_PATH $TILE_URL
            done
        done
    done
}

echo "Downloading tiles for broad coverage (zoom levels 0–2)..."

# Broad coverage (world-level view)
download_tiles 20 45 20 50 0 2  # Middle East and Mediterranean

echo "Downloading detailed tiles for Jerusalem (zoom levels 3–6)..."

# Detailed tiles around Jerusalem
download_tiles 31.5 32.5 35 36 3 6  # Focus on Jerusalem

echo "Downloading detailed tiles for Greece (zoom levels 3–5)..."

# Detailed tiles around Greece
download_tiles 37 40 22 25 3 5  # Focus on Greece

echo "Downloading detailed tiles for Babylon (zoom levels 3–5)..."

# Detailed tiles around Babylon
download_tiles 32 33 44 45 3 5  # Focus on Babylon

echo "Tile download complete. Saved in $TILE_DIR."
