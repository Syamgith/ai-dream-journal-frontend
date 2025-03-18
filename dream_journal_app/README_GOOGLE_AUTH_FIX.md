# Fixing Google Sign-In Error

This document provides instructions to fix the error:

```
Error: Assertion failed: file:///Users/syamgith/.pub-cache/hosted/pub.dev/google_sign_in_web-0.12.4+4/lib/google_sign_in_web.dart:144:9
appClientid != null
"ClientID not set. Either set it on a <meta name=\"google-signin-client_id\" content=\"CLIENT_ID\" /> tag, or pass clientId when initializing
```

## 1. Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Go to APIs & Services > OAuth consent screen
   - Configure the OAuth consent screen (external or internal)
   - Add necessary scopes (email, profile)
4. Go to APIs & Services > Credentials
   - Create OAuth 2.0 client IDs for each platform you need:
     - Web application
     - Android
     - iOS

## 2. Update Configuration Files

### A. Create/Update .env File

Copy the `.env.example` file to `.env` and add your actual client IDs:

```
# API Configuration
API_URL=https://yourapiurl.com/api

# Google OAuth Configuration
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=your-ios-client-id.apps.googleusercontent.com
```

### B. Update Web Configuration

Edit `web/index.html` and update the Google client ID meta tag with your actual web client ID:

```html
<meta
  name="google-signin-client_id"
  content="YOUR_ACTUAL_WEB_CLIENT_ID.apps.googleusercontent.com"
/>
```

## 3. Android Configuration

For Android, you need to configure the application's SHA-1 signature in the Google Cloud Console:

1. Generate the SHA-1 signature:

   ```bash
   cd android
   ./gradlew signingReport
   ```

2. Add the SHA-1 fingerprint to your OAuth client ID in Google Cloud Console:
   - Navigate to APIs & Services > Credentials
   - Edit your Android OAuth client
   - Add the SHA-1 fingerprint

## 4. iOS Configuration

For iOS, update the `ios/Runner/Info.plist` file to include the reversed client ID:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR-ACTUAL-IOS-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

## 5. Test the App

After applying these changes, rebuild the app and test Google Sign-In on all platforms.

## Common Issues and Solutions

### Web Platform Issues

- Make sure the client ID is the same in both `index.html` and `.env` file
- Verify that your web application is authorized in the Google Cloud Console
- Ensure the correct origins are allowed in your OAuth client configuration

### Android Issues

- Verify that the SHA-1 fingerprint in Google Cloud Console matches your app's actual fingerprint
- Check that the package name in Google Cloud Console matches your AndroidManifest.xml
- Make sure the Google Play Services is up to date on the test device

### iOS Issues

- Ensure the Bundle ID in Google Cloud Console matches your app's Bundle ID
- Verify the reversed client ID format in Info.plist is correct
