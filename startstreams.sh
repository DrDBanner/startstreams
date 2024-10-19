#!/bin/bash
# Version 0.02
# JSON file containing general video stream details and Twitch OAuth Key
VideoJsonFile="video_channels.json"

# Default JSON content with instructions
default_json_content='{
  "info": "This file contains the video channels/streams to be played. Set the value of enabled to true to activate a stream. Add new channels/streams under GeneralVideoChannels, if you put a channel URL the script casts for all live broadcasts automatically and plays them. TwitchOAuthKey is required for Twitch streams to avoid commercial breaks.",
  "TwitchOAuthKey": "",
  "TwitchChannels": [
    {
      "url": "https://www.twitch.tv/k1m6a",
      "enabled": 1,
      "note": "KimbaTwitch"
    },
    {
      "url": "https://www.twitch.tv/some_other_channel",
      "enabled": 0,
      "note": "PleaseNoWhitespace"
    }
  ],
  "GeneralVideoChannels": [
    {
      "url": "https://www.youtube.com/@k1m6a/live",
      "enabled": 1,
      "note": "KimbaYouTube"
    },
    {
      "url": "https://www.youtube.com/@livebookmap/streams",
      "enabled": 1,
      "note": "LiveBookmap"
    },
    {
      "url": "https://www.youtube.com/@paulbetteridge/live",
      "enabled": 1,
      "note": "ES_Orderflow"
    }
  ]
}
'

# Function to check and create the JSON file if it doesn't exist
function check_and_create_json {
    if [ ! -f "$VideoJsonFile" ]; then
        echo "JSON file does not exist. Creating $VideoJsonFile with default data..."
        echo "$default_json_content" > "$VideoJsonFile"
        echo "The file $VideoJsonFile has been created. You can modify it to control which streams are played."
    #   else
    #   echo "The file $VideoJsonFile exists. Reading values."
    fi
}

# Function to validate and fix the JSON file
fix_json() {
    local json_file="$1"

    if ! jq empty "$json_file" > /dev/null 2>&1; then
        echo "Invalid JSON file found. Attempting to fix the file..."

        # Attempt to reformat the JSON file
        jq '.' "$json_file" 2>/dev/null > "${json_file}.tmp" && mv "${json_file}.tmp" "$json_file"
        
        # Recheck the file
        if jq empty "$json_file" > /dev/null 2>&1; then
            echo "The JSON file has been fixed."
        else
            echo "Error fixing the JSON file. Please check it manually."
        fi
    else
        echo "The JSON file is valid."
    fi
}

prerequisites() {

# Function to check if a program is installed
function check_program_installed {
    if ! command -v $1 &> /dev/null; then
        return 1  # Program is not installed
    else
        return 0  # Program is installed
    fi
}

# Check if Homebrew is installed
if ! check_program_installed brew; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/opt/homebrew/bin:$PATH"
    # else
    # echo "Homebrew is already installed."
fi

# Initialize VLC command variable
vlc_cmd=""

# Check if VLC is installed
if check_program_installed vlc; then
    vlc_cmd="vlc"
    #echo "VLC is installed and available via command line."
elif [ -d "/Applications/VLC.app" ]; then
    vlc_cmd="/Applications/VLC.app/Contents/MacOS/VLC"
    #echo "VLC is installed as an application."
else
    echo "VLC is not installed. Installing VLC via Homebrew..."
    brew install --cask vlc
    vlc_cmd="vlc"
fi

# Check and install yt-dlp if necessary
if ! check_program_installed yt-dlp; then
    echo "yt-dlp is not installed. Installing yt-dlp..."
    brew install yt-dlp
    #else
    #echo "yt-dlp is already installed."
fi

# Check and install Streamlink if necessary
if ! check_program_installed streamlink; then
    echo "Streamlink is not installed. Installing Streamlink..."
    brew install streamlink
    #else
    #echo "Streamlink is already installed."
fi

# Check and install jq if necessary
if ! check_program_installed jq; then
    echo "Jq is not installed. Installing jq..."
    brew install jq
    #else
    #echo "Jq is already installed."
fi
}

# Function to start Twitch streams from the JSON file
start_twitch_streams() {
    # echo "Starting Twitch streams..."
    check_and_create_json
    fix_json "$VideoJsonFile"

    # Read Twitch OAuth Key
    TwitchOAuthKey=$(jq -r '.TwitchOAuthKey // empty' "$VideoJsonFile")
    echo "Twitch OAuth Key: $TwitchOAuthKey"

    if [ -z "$TwitchOAuthKey" ]; then
        printf "\e[31mTwitch OAuth Key is missing in the JSON file. Please add it to stream Twitch channels without commercial breaks.\e[0m\n"
    fi

    # Read Twitch channels
    twitch_channels=$(jq -c '.TwitchChannels[]' "$VideoJsonFile") || {
        printf "\e[31mError reading Twitch channels from JSON. Please check the file for any syntax problems.\e[0m\n"
        return
    }

    for channel_data in $twitch_channels; do
    
    #echo "Channel Data: $channel_data"  # Debugging-Ausgabe
    
    url=$(echo "$channel_data" | jq -r '.url // empty')
    enabled=$(echo "$channel_data" | jq -r '.enabled // empty')
    note=$(echo "$channel_data" | jq -r '.note // empty')
    
    #echo "Channel URL: $url"
    #echo "Channel Enabled: $enabled"
    #echo "Channel Note: $note"
    
    if [[ "$enabled" == "1" ]] && [ -n "$url" ]; then
        echo "Starting Twitch stream: $note ($url)"
        streamlink --twitch-low-latency --title "$note" --player-args "$VlcStartupParameters" "--twitch-api-header=Authorization=OAuth $TwitchOAuthKey" "$url" best &
        #else
        #echo "Twitch stream disabled: $note ($url)"
    fi
done
}

# Function to check if a URL is a YouTube channel or specific video
is_youtube_channel() {
    local url=$1
    echo "Checking URL: $url"  # Debugging-Ausgabe
    if [[ "$url" =~ ^https:\/\/(www\.)?youtube\.com\/(c|channel|user|@)[a-zA-Z0-9_-]+(/streams)?$ ]]; then
        echo "Detected as YouTube Channel."
        return 0  # It's a channel URL
    elif [[ "$url" =~ ^https:\/\/(www\.)?youtube\.com\/(watch\?v=|@.*\/live)$ ]]; then
        echo "Detected as Specific Video URL."
        return 1  # It's a specific video URL
    else
        echo "URL is not a valid YouTube channel or video."
        return 2  # Invalid URL
    fi
}

VlcStartupParameters="--playlist-autostart"


# Function to start General Video streams (YouTube and other video platforms) from the JSON file
start_general_video_streams() {
    echo "Starting general video streams..."

    # Check and create JSON file if needed
    check_and_create_json

    # Read JSON file and parse with jq
    general_video_streams=$(jq -c '.GeneralVideoChannels[]' "$VideoJsonFile")

    # Array to hold live streams
    live_streams=()

    for stream_data in $general_video_streams; do
        url=$(echo "$stream_data" | jq -r '.url // empty')
        enabled=$(echo "$stream_data" | jq -r '.enabled // empty')  # Expecting 0 or 1
        note=$(echo "$stream_data" | jq -r '.note // empty')

        # Ensure enabled is treated as a number (0 or 1)
        if [[ "$enabled" == "1" ]]; then
            echo "Processing Data: $note ($url), Status: $enabled"

            # Check if it's a YouTube channel
            if is_youtube_channel "$url"; then
                echo "Searching for live broadcasts on the YouTube channel: $url"

                # Initialize an empty variable for live streams
                temp_live_streams=""

                # Start a loop to wait for the live streams with a timeout
                timeout_duration=30
                end_time=$((SECONDS + timeout_duration))

                while [ $SECONDS -lt $end_time ]; do
                    # Fetch live streams from the YouTube channel
                    temp_live_streams=$(yt-dlp --flat-playlist -J "$url" | jq -r '.entries[] | select(.live_status == "is_live") | .url')

                    # Check if live streams were found
                    if [ -n "$temp_live_streams" ]; then
                        echo "Found live streams:"
                        live_streams+=($temp_live_streams)  # Append found streams to the array
                        break  # Exit the waiting loop if streams are found
                    else
                        echo "No live streams found yet. Retrying in 5 seconds..."
                        sleep 5  # Wait a few seconds before retrying
                    fi
                done

                # After the loop, check if we found any live streams
                if [ -z "$temp_live_streams" ]; then
                    echo "No live streams found for this channel: $url after $timeout_duration seconds."
                fi
            else
                # If the URL is a direct video URL, start it directly
                echo "Starting specific video stream: $url ($note)"
                "$vlc_cmd" "$VlcStartupParameters" "$url" > /dev/null 2>&1 &
            fi
            # else
            # Debug output for streams that are disabled
            # echo "Skipping stream: $note ($url) because it is disabled (Status: $enabled)"
        fi
    done

    # Start all found live streams
    if [ ${#live_streams[@]} -gt 0 ]; then
        for stream in "${live_streams[@]}"; do
            echo "Starting live stream: $stream"
            "$vlc_cmd" "$VlcStartupParameters" "$stream" > /dev/null 2>&1 &
        done
        # else
        # echo "No streams to start."
    fi
}


# Function to stop all running streams
stop_streams() {
    killall VLC > /dev/null 2>&1 &
    killall streamlink > /dev/null 2>&1 &
}

# Function to start both Twitch and General Video streams
startstreams() {
    stop_streams
    start_twitch_streams
    start_general_video_streams
}

# Check for command line argument
if [[ "$1" == "kill" ]]; then
    stop_streams
else
    prerequisites
    startstreams
fi
