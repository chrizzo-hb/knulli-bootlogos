#!/bin/bash

# Function to get confirmation using the dialog command
confirm_action() {
    local prompt="$1"
    local action="$2"
    local height="${3:-7}"
    local width="${5:-50}"

    dialog --yesno "$prompt" $height $width
    response=$?

    clear

    case $response in
        0) eval "$action"; return 0 ;;
        1) echo "Action canceled."; return 1 ;;
        255) echo "Action canceled."; return 1 ;;
    esac
}

# Function to handle the first confirmation (selecting a new boot logo)
confirm_boot_logo() {
    local file="$(basename "$1")"
    confirm_action "You selected '$file'.\n\nDo you want to set it as your new boot logo?" \
        "true" 8 60 || exit 1
}

# Function to handle the second confirmation (reboot)
confirm_reboot() {
    confirm_action "Do you want to reboot the system now?" "reboot" || echo "Reboot skipped."
}

make_boot_logo() {
    local file="$1"
    if [ -f "$file" ]; then
        # Set boot partition to RW
        [[ ! -w /boot/bootlogo.bmp ]] && batocera-es-swissknife --remount

        # Copy new bootlogo
        cp "$file" /boot/bootlogo.bmp

        batocera-es-swissknife --remount

        # After setting the boot logo, ask if the user wants to reboot
        confirm_reboot
    else
        echo "Logo file ($logo_file) does not exist."
    fi
}

select_file_dialog() {
    DIRECTORY=${1:-/userdata/roms/pygame/change-bootlogo/bootlogo}

    # Check if the provided argument is a valid directory
    if [ ! -d "$DIRECTORY" ]; then
        echo >&2 "ERROR: $DIRECTORY is not a valid directory."
        exit 1
    else
        # Create a file list with numbered items for the dialog
        files=("$DIRECTORY"/*.bmp)
        file_list=()
        for i in "${!files[@]}"; do
            file_list+=("$i" "$(basename "${files[$i]}")")
        done

        # Use dialog to present the list to the user
        if [ ${#file_list[@]} -eq 0 ]; then
            echo >&2 "No files found in the directory."
            selected_file=""
        else
            # Display the dialog box and capture the user's choice
            selection=$(dialog --menu "Select a file" 15 60 10 "${file_list[@]}" 2>&1 >/dev/tty)

            # Clear the dialog box from the terminal
            clear 2>&1 >/dev/tty

            # Check if the user made a selection
            if [ -z "$selection" ]; then
                echo >&2 "No file selected."
                selected_file=""
            else
                # Get the selected file
                echo >>/tmp/selection.txt "DEBUG: $selection"
                selected_file="${files[$selection]}"
            fi
        fi
    fi
    echo "$selected_file"
}

if [ ! -z "$1" ]; then
    logo_file="$1"
else
    logo_file="$(select_file_dialog /userdata/roms/pygame/change-bootlogo/bootlogo)"
fi

if [ -f "$logo_file" ]; then
    confirm_boot_logo "$logo_file"
    make_boot_logo "$logo_file"
fi
