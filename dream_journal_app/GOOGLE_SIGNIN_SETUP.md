# Google Sign-In Setup

This document provides instructions for setting up Google Sign-In for the Dream Journal app.

## Required Steps

### 1. Create a Google Cloud Project (if not already done)

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Create a new project or select an existing one.
3. Enable the "Google Sign-In API" from the API Library.

### 2. Android Setup

#### a. Configure SHA-1 Fingerprint

1. Generate SHA-1 fingerprint for your app:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Take note of the SHA-1 fingerprint from the debug section.

#### b. Create OAuth Client

1. Go to Google Cloud Console > APIs & Services > Credentials.
2. Create an OAuth 2.0 client ID for Android.
3. Enter your package name (from AndroidManifest.xml).
4. Add the SHA-1 fingerprint you generated earlier.

### 3. iOS Setup

#### a. Update Info.plist

Add the following to your `ios/Runner/Info.plist` file:

```xml
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- Replace with your reversed client id from GoogleService-Info.plist -->
			<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
		</array>
	</dict>
</array>
```

#### b. Create OAuth Client

1. Go to Google Cloud Console > APIs & Services > Credentials.
2. Create an OAuth 2.0 client ID for iOS.
3. Enter your Bundle ID.

### 4. Configure Backend

Ensure your backend server is configured to handle Google authentication via the `/auth/google` endpoint.

### 5. Assets Setup

Make sure to download the Google logo image and place it at `assets/images/google_logo.png` for the sign-in button to display correctly.

## Troubleshooting

### Common Android Issues

- Make sure the SHA-1 fingerprint in the Google Cloud Console matches your app's fingerprint.
- Check that the package name in Google Cloud Console matches your AndroidManifest.xml.

### Common iOS Issues

- Ensure the Bundle ID in Google Cloud Console matches your app's Bundle ID.
- Make sure the reversed client ID in Info.plist is correct.

### Other Issues

- Check the app logs for detailed error messages.
- Ensure the device/emulator has internet connectivity.
- Verify that the Google Sign-In API is enabled in Google Cloud Console.
