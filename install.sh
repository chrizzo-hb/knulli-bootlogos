#!/bin/bash

download_data="
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/change-bootlogo.sh /opt/change-bootlogo.sh true
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/info.txt /userdata/system/patches/bootlogo/info.txt false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/bootlogo_original.bmp /userdata/system/patches/bootlogo/bootlogo_original.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/powered_by_knulli_greyscale_v2.bmp /userdata/system/patches/bootlogo/powered_by_knulli_greyscale_v2.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/powered_by_knulli_greyscale.bmp /userdata/system/patches/bootlogo/powered_by_knulli_greyscale.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/powered_by_knulli_v2.bmp /userdata/system/patches/bootlogo/powered_by_knulli_v2.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/powered_by_knulli.bmp /userdata/system/patches/bootlogo/powered_by_knulli.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/rg35xx-h_anbernic.bmp /userdata/system/patches/bootlogo/rg35xx-h_anbernic.bmp false
https://raw.githubusercontent.com/zarquon-42/knulli-bootlogos/refs/heads/main/bootlogo/rg35xx-h_device.bmp /userdata/system/patches/bootlogo/rg35xx-h_device.bmp false
"
download_files() {
    echo "$1" | while IFS=" " read -r uri target_file executable; do
        # Skip empty lines
        if [ -z "$uri" ]; then
            continue
        fi

        mkdir -p "$(dirname "$target_file")"

        echo -n "    Downloading $(basename "$target_file")..."
        curl \
            --silent \
            $uri \
            --output $target_file \
        || return 1

        if [ "$executable" = "true" ]; then
            chmod +x $target_file
        fi
        echo " Complete"
    done
}

rotate_bmps() {
    local dir="${1:-/userdata/system/patches/bootlogo}"

    local board=$(batocera-info | grep '^Board: ' | sed -e 's/^Board: //' | tr '[:upper:]' '[:lower:]')

    if [[ "$board" == "rg28xx" ]]; then
        # Rotate each .bmp file in the directory by 270 degrees
        echo "Rotate Images by 270 degrees..."
        for file in "$dir"/*.bmp; do
            if [ -f "$file" ]; then
                echo -n "    Rotating $(basename "$file")..."
                ffmpeg -y -v 0 -i "$file" -vf "rotate=PI*1.5:ow=ih:oh=iw" "$file.rotated.bmp"
                mv "$file.rotated.bmp" "$file"
                echo " Complete"
            fi
        done
    fi
}

# Download generate scripts and set permissions
echo "Downloading Script and Bootlogos..."
download_files "$download_data" && \
rotate_bmps && \
echo -n "Making changes permanent..." && \
batocera-save-overlay >/dev/null && \
echo " Complete" && \
echo "" && \
echo "Installation Complete" && \
echo "" && \
echo "
Usage: /opt/change-bootlogo.sh
"