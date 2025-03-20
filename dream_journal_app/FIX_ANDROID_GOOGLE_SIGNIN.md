# Fix for Google Sign-In on Android

This guide provides step-by-step instructions to fix the Google Sign-In issue on Android where the ID token is null.

## Problem

When attempting to sign in with Google on Android, the authentication fails because the ID token is null, as shown in the logs:

```
I/flutter (15594): Google User: GoogleSignInAccount:{displayName: Syamgith, email: syamgithksudheesh@gmail.com, id: 104758106366272972413, photoUrl: https://lh3.googleusercontent.com/a/ACg8ocK1y852SA7OLmQ7Ny-QAPhaVDzILzcF-tGlw9xBLomLMy-P9mGi, serverAuthCode: null}
I/flutter (15594): Google Auth: GoogleSignInAuthentication:Instance of 'GoogleSignInTokenData'
I/flutter (15594): ID Token: null
I/flutter (15594): Access Token: ya29.a0AeXRPp7tPX9FwFFHnPEqG0SK3-MBuoBAtoAnqG26NIoR-HCSQy8lZJYyA7PAFiF-otGHx5NUjKE6qiLskvAoVHWaOwYJJYjiBuOZEig688PZEf4zI_9XVrXvLj8gctMNenFVm3Uzkg2AIKzRewy4KJ4Uv73k3xBpffzsiszTaCgYKAUYSARMSFQHGX2Min95D9jx9pcpZBA-xbrTtDA0175
```

## Solution

The solution has two parts:

1. **Frontend Update**: Modify the Flutter app to send the access token when the ID token is null
2. **Backend Update**: Update the backend to handle both token types

## Step 1: Frontend Update

The `auth_repository.dart` file has been modified to handle both token types. The changes include:

- Using the access token as a fallback when the ID token is null
- Sending a `token_type` parameter to indicate which token is being used

## Step 2: Backend Update

The backend API endpoint that handles Google authentication needs to be updated to:

1. Accept the new `token_type` parameter
2. Handle validation for both ID tokens and access tokens
3. Extract user information appropriately from either token type

See `BACKEND_GOOGLE_SIGNIN_UPDATE.md` for detailed implementation instructions.

## Testing the Fix

To test the fix:

1. Build and run the app on an Android device
2. Attempt to sign in with Google
3. Check the logs to confirm the access token is used when ID token is null
4. Verify that authentication completes successfully

## Common Issues

- **SHA-1 Certificate Fingerprint**: Ensure your SHA-1 fingerprint is correctly added to the Google Cloud Console for Android
- **OAuth Scopes**: Make sure you've requested the appropriate scopes ('openid', 'email', 'profile')
- **Google Play Services**: Verify that Google Play Services is up-to-date on the test device
- **Network Connectivity**: Ensure the device has proper internet connectivity

## Additional Notes

On some Android devices, Google Sign-In may provide ID tokens, while on others it might only provide access tokens. The updated implementation handles both scenarios seamlessly.

If you encounter any other issues, please check the Google Sign-In documentation and ensure your Google Cloud project configuration is correct.
