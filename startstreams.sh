#!/bin/bash
# Put your personal Twitch OAuth Key here, to prevent commercial breaks.
TwitchOAuthKey=''

# Global comma-separated channel strings for Twitch and YouTube. Basically, you can add any string that's supported by Streamlink (TwitchChannelsString) or VLC (YouTubeChannelsString).
TwitchChannelsString="https://www.twitch.tv/k1m6a"
YouTubeChannelsString="https://www.youtube.com/watch?v=LWwvKar_epc,https://www.youtube.com/watch?v=c2YUV_0ubhc,https://www.youtube.com/watch?v=GZksw7k5ykU,https://www.youtube.com/watch?v=bQ9R0ERP1YI,https://www.youtube.com/watch?v=_6Wigc8yKRA"

VlcStartupParameters="--playlist-autostart"

######## Below this line only if you know what you do!

# Convert the comma-separated strings to arrays
IFS=',' read -r -a TwitchChannels <<< "$TwitchChannelsString"
IFS=',' read -r -a YouTubeChannels <<< "$YouTubeChannelsString"

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
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Ensure that brew is added to the PATH after installation
    export PATH="/opt/homebrew/bin:$PATH"
else
    echo "Homebrew is already installed."
fi

# Initialize VLC command variable
vlc_cmd=""

# Check if VLC is installed
if check_program_installed vlc; then
    vlc_cmd="vlc"
    echo "VLC is installed and available via command line."
elif [ -d "/Applications/VLC.app" ]; then
    vlc_cmd="/Applications/VLC.app/Contents/MacOS/VLC"
    echo "VLC is installed as an application."
else
    echo "VLC is not installed. Installing VLC via Homebrew..."
    brew install --cask vlc
    vlc_cmd="vlc"
fi

# Check and install Streamlink if necessary
if ! check_program_installed streamlink; then
    echo "Streamlink is not installed. Installing Streamlink..."
    brew install streamlink
else
    echo "Streamlink is already installed."
fi

echo "All required programs are installed and ready."

start_twitch_stream() {
    echo "Starting Twitch streams..."
    for channel in "${TwitchChannels[@]}"; do
        streamlink --twitch-low-latency --player-args "$VlcStartupParameters" "--twitch-api-header=Authorization=OAuth $TwitchOAuthKey" "$channel" best &
        echo "Starting '$channel'" &
    done
}

start_youtube_stream() {
    echo "Starting YouTube streams..."
    # Loop through the YouTube streams and open each one in VLC
    for stream_url in "${YouTubeChannels[@]}"; do
        "$vlc_cmd" "$VlcStartupParameters" "$stream_url" > /dev/null 2>&1 &
        echo "Starting '$stream_url'" &
    done

    echo "YouTube streams started..."
}

stop_streams() {
    echo "Stopping all streams..."
    killall VLC
    killall streamlink
}

startstreams() {
    stop_streams
    start_twitch_stream
    start_youtube_stream
}

# Check for command line argument
if [[ "$1" == "kill" ]]; then
    stop_streams
else
    startstreams
fi
