# RokuCal - Google Calendar Display for Roku

A system that displays Google Calendar events on a Roku TV with high contrast design for vision accessibility.

## Features

- Displays current and next 4 day's calendar events
- High contrast design (black background, white text, yellow event highlights)
- Large, bold fonts for easy reading
- REST API fetches events from private Google Calendar

## PHP API Setup

1. Install Composer dependencies:
   ```bash
   composer install
   ```

2. Set up Google Calendar API credentials:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable the Google Calendar API
   - Create credentials (OAuth 2.0 client ID) for a desktop application
   - set the redirect URI to http://localhost:8000
   - Download the credentials JSON file and save as `credentials.json`

3. Run the authentication setup:
   ```bash
   php setup_auth.php
   ```
   Follow the prompts to authenticate and save your token.

4. Start your web server:
   ```bash
   php -S localhost:8000
   ```

5. Test the API by visiting `http://localhost:8000/calendar_api.php`
	> update the $calendarID in this file if you want something other than the primary calendar

## Roku App Setup

1. The Roku app files are in the `roku_app/` directory

2. Update the API URL in `roku_app/components/CalendarScene.brs`:
   - Replace `YOUR_SERVER_IP` with your actual server IP address
   - Example: `http://192.168.1.100:8000/calendar_api.php`

3. Add required placeholder images to `roku_app/images/`:
   - `icon_focus_hd.png` (336x210)
   - `icon_side_hd.png` (108x69)
   - `icon_focus_sd.png` (248x140)
   - `icon_side_sd.png` (80x46)
   - `splash_hd.png` (1280x720)
   - `splash_sd.png` (720x480)

4. Package and side-load the app to your Roku device:
   - Enable Developer Mode on your Roku (https://www.howtogeek.com/290787/how-to-enable-developer-mode-and-sideload-roku-apps/)
   - Package the `roku_app` folder as a ZIP file
   - Upload via the Roku Developer web interface

