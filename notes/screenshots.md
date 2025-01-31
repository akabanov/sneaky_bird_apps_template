# Notes on app screenshots

## Google Play Store requirements (as of Jan 2025)

4-8 screenshots per language / size class.

Screenshots must be
- PNG or JPEG
- up to 8 MB each
- 16:9 or 9:16 aspect ratio

## Apple App Store requirements (as of Jan 2025)

[Display properties](https://www.ios-resolution.com/) of every iPhone, iPad, iPod touch and Apple Watch ever made.

App Store Connect [has a limit](https://docs.fastlane.tools/actions/upload_to_app_store/#limit)
of 150 binary uploads per day.

[Perfect status bar](https://github.com/shinydevelopment/SimulatorStatusMagic)
(not required, but is a sign of excellence):

- 9:41 AM is displayed for the time
- The battery is full and shows 100%
- 5 bars of cellular signal and full Wi-Fi bars are displayed
- Tue Jan 9 is displayed for the date (iPad only)

Notes:

- Up to 3 app previews and 10 screenshots (what is the difference??)
- We'll use these screenshots for all display sizes and localizations
- Screenshots are only required for iOS apps and only the first 3 will be used on the app installation sheets
- Portrait and landscape are allowed
- If a size missing, a bigger one is used for display
