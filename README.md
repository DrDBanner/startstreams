# startstreams

**Effortlessly Open Multiple Video Streams via VLC Media Player** 

This script allows you to enjoy video streams in beautifully arranged small windows while keeping CPU usage minimal. macOS only sorry.

![screenshot](https://github.com/user-attachments/assets/8adb62a1-0515-48b2-8a49-8cabde01f480)

## Notes

- You can restart all streams by running the script again. To stop all streams, use the command:

   ```./startstreams.sh kill```

- The script automatically installs VLC and Streamlink if they are not already present on your system.
- If you have a Twitch channel subscription and do not provide your OAuth key, you may encounter commercial breaks during streams.
- During first run a json file is created. Within that file you can customize the streams and channels and put your twitch oauth key.
- If you put in a channel URL (e.g.: https://www.youtube.com/@k1m6a) instead of a video url (https://www.youtube.com/@k1m6a/live) the script casts for ALL live streams and starts them automatically.
- Title/note fields lac of whitespace support. So, just don't put whitespaces.
  
## Usage

To get started, follow these steps:

1. Open Terminal by pressing **[CMD] + [Space]**, typing "Terminal", and hitting **[ENTER]**.
2. Copy and paste the following command into the terminal:

   ```bash
   curl -O https://raw.githubusercontent.com/DrDBanner/startstreams/refs/heads/main/startstreams.sh && chmod +x startstreams.sh
   ```

3. Execute the script with:

   `sh startstreams.sh`

   or 

   `./startstreams.sh`

### How to Obtain Your Twitch OAuth Key

To get your personal OAuth token from Twitch:

1. Visit **Twitch.tv** and log into your account.
2. Open your browser's Developer Tools (press **F12** or **CTRL + SHIFT + I**).
3. Navigate to the **Console** tab and execute the following JavaScript code:

   `document.cookie.split("; ").find(item => item.startsWith("auth-token="))?.split("=")[1]`

4. Copy the resulting 30-character alphanumeric string and paste it into the `TwitchOAuthKey` variable in the `startstreams.sh` file.
