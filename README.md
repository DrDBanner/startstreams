# startstreams
Open video streams via VLC media player, which gives you beautiful small windows side by side each while consuming very little CPU power.
MacOS only.

<img width="1280" alt="screenshot" src="https://github.com/user-attachments/assets/8adb62a1-0515-48b2-8a49-8cabde01f480">



## Usage 
[Download startstreams.sh](https://github.com/DrDBanner/startstreams/blob/b1b50baa4c8b4780f5ea42f88f1da2ec7206c124/startstreams.sh) file, open Terminal ([CMD] + [Space] -> Type: "terminal" -> Hit [ENTER]), navigate to scripts location and exectute with `sh startstreams.sh` or `./startstreams.sh` if the file has execution permission.

## Notes: 
- Be sure this script is executable: `chmod +x startstreams.sh`
- You can call the script twice to restart all streams. You can call it with the command line parameter kill `sh ./startstreams.sh kill` in oder to stop all streams.
- VLC and Streamlink need to be installed. They'll get installed automatically if they're not present.
- If you do have a Twitch channel subscription and if you do not enter your OAuthKey you'll face commercial breaks regularly.
- Currently, some streams are hardcoded within the script, so if you wand to add or remove streams, open the file and alter it according to your needs. 

### How to obtain TwitchOAuthKey 
In order to get your personal OAuth token from Twitch's website which identifies your account, open Twitch.tv in your web browser and after a successful login, open the developer tools by pressing F12 or CTRL+SHIFT+I. Then navigate to the "Console" tab or its equivalent of your web browser and execute the following JavaScript snippet:

`document.cookie.split("; ").find(item=>item.startsWith("auth-token="))?.split("=")[1]`

Copy the resulting string consisting of 30 alphanumerical characters into the TwitchOAuthKey variable field within the startstreams.sh file.
