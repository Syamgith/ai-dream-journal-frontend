# Backend Google Sign-In Update Guide

This document provides instructions for updating the backend to handle both ID tokens and access tokens from Google Sign-In.

## Background

The Flutter front-end has been updated to handle Google Sign-In on Android devices where the ID token may not be available. In such cases, the front-end now sends the access token with a `token_type` parameter to indicate which type of token is being sent.

## Required Backend Changes

The backend API endpoint `/users/auth/google` needs to be updated to:

1. Accept a new `token_type` parameter with possible values:

   - `id_token` (the traditional flow using ID tokens)
   - `access_token` (new flow for cases where ID token is unavailable)

2. Add logic to validate and extract user information from either token type:
   - For `id_token`: Continue using the existing JWT verification logic
   - For `access_token`: Make a request to Google's userinfo endpoint to get user details

## Implementation Guide

### 1. Update API Schema

Update the API schema to accept the new parameter:

```javascript
// Example for a Node.js Express backend
const googleAuthSchema = {
  token: Joi.string().required(),
  token_type: Joi.string()
    .valid("id_token", "access_token")
    .default("id_token"),
};
```

### 2. Update Google Auth Handler

Update the auth handler to handle both token types:

```javascript
// Example implementation for Node.js
async function handleGoogleAuth(req, res) {
  const { token, token_type } = req.body;

  try {
    let userData;

    if (token_type === "id_token") {
      // Existing ID token verification logic
      const ticket = await client.verifyIdToken({
        idToken: token,
        audience: [webClientId, androidClientId, iOSClientId],
      });
      userData = ticket.getPayload();
    } else if (token_type === "access_token") {
      // New access token verification logic
      const response = await axios.get(
        "https://www.googleapis.com/oauth2/v3/userinfo",
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );
      userData = response.data;
    }

    // Continue with user creation/login using userData
    // ...

    res.json({
      access_token: generatedAccessToken,
      refresh_token: generatedRefreshToken,
      user: userObject,
    });
  } catch (error) {
    res.status(401).json({ error: "Invalid token" });
  }
}
```

### 3. Testing

Test the endpoint with both token types:

1. Test with ID token (web, some Android devices)
2. Test with access token (Android devices where ID token is null)

## Security Considerations

- Verify that the access token is valid by checking with Google's userinfo endpoint
- Validate the email is verified before creating/logging in a user
- Implement rate limiting to prevent abuse
