# startstreams

**Effortlessly Open Multiple Video Streams via VLC Media Player** --macOS only!

This script allows you to enjoy video streams in beautifully arranged small windows while keeping CPU usage minimal. If you add a YouTube Channel URL it casts for all live broacasting streams and plays them all in one go.

![sc1](https://github.com/user-attachments/assets/a02afcea-b932-4a65-9c29-e774e333121c)


## Notes

- You can restart all streams by running the script again. To stop all streams, use the command:

   ```./startstreams.sh kill```

- The script automatically installs VLC and Streamlink if they are not already present on your system.
- If you have a Twitch channel subscription and do not provide your OAuth key, you may encounter commercial breaks during streams.
- During first run a json file is created. It comes prepopulated to you, so it starts with content from the get go. Within that file you can customize the streams and channels and put your twitch oauth key.
- If you put in a channel URL (e.g.: https://www.youtube.com/@k1m6a) instead of a video url (https://www.youtube.com/@k1m6a/live) the script casts for ALL live streams and starts them automatically.
- Title/note fields lack of whitespace support. Jq breaks then. So, just don't put whitespaces.
  
## Usage

To get started, follow these steps:

1. Open Terminal by pressing **[CMD] + [Space]**, typing "Terminal", and hitting **[ENTER]**.
2. Copy and paste the following command into the terminal for installation and for updating the script to the latest version:

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

<img width="1684" alt="Bildschirmfoto 2024-10-20 um 16 26 14" src="https://github.com/user-attachments/assets/bbce8d41-0095-4bda-b3d4-011f45e2c85f">

4. Copy the resulting 30-character alphanumeric string and paste it into the automatically created `video_channels.json` file.

<img width="1278" alt="Bildschirmfoto 2024-10-21 um 09 13 29" src="https://github.com/user-attachments/assets/8d5e5c47-f2e4-4c0a-94b6-b671eed56b4a">

   
