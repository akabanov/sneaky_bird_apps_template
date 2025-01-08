# Notes on app screenshots

[Fastlane for Flutter projects.](https://docs.flutter.dev/deployment/cd#fastlane)

## Google Play Store requirements (as of Jan 2025)

4-8 screenshots per language / size class.

Screenshots must be
- PNG or JPEG
- up to 8 MB each
- 16:9 or 9:16 aspect ratio

tbd: formalise sizes (or accept what's already implemented)

### Phone

Each side between 1080 px and 3840 px

### 7-inch tablet

Each side between 1080 px and 3840 px (same size as phone; density?)

### 10-inch tablet

Each side between 1080 px and 7680 px

### Chromebook

Each side between 1080 px and 7680 px (same size as 10 inch; density?)

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

### iPhone 6.7" or 6.9" Display (mandatory)

- 1320 × 2868 px /3: (6.9) 16 Pro Max
- 1290 × 2796 px /3: (6.7) 16 Plus, 15 Pro Max, 15 Plus, 14 Pro Max

### iPhone 6.5" Display

- 1242 × 2688 px /3: Xs Max

### iPhone 5.5" Display

- 1080 x 1920 px /3: 8 Plus

tbd: smaller sizes

### iPad 12.9" or iPad 13" Display (mandatory)

- 2064 × 2752 px /2: Pro 7th gen 13"
- 2048 × 2732 px /2: Pro 4/5th gen 12.9"

tbd: smaller sizes


