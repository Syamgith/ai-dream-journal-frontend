# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Dreami Diary** - A Flutter dream journal app that allows users to record, track, and analyze their dreams using AI. The app features Google Sign-in authentication, secure storage, and integrates with a backend API for dream interpretation and pattern analysis.

**Key Technologies:**
- Flutter/Dart (SDK >=2.17.0)
- Riverpod for state management
- Google Sign-in authentication
- Flutter Secure Storage for tokens
- HTTP client with custom token interceptor

## Development Commands

### Environment Setup

```bash
# Navigate to app directory
cd dream_journal_app

# Install dependencies
flutter pub get

# Create .env file with required variables:
# API_URL=your_api_url
# GOOGLE_CLIENT_ID=your_google_client_id
```

### Running the App

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices
```

### Building

```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Build for Web
flutter build web
```

### Testing & Analysis

```bash
# Run tests
flutter test

# Run analyzer
flutter analyze

# Clean build artifacts
flutter clean
```

## Architecture

### Feature-First Structure

The codebase follows a feature-first architecture with clean separation:

```
lib/
├── core/                    # Shared core functionality
│   ├── auth/               # AuthService for secure storage
│   ├── config/             # Environment configuration
│   ├── network/            # ApiClient with TokenInterceptor
│   ├── providers/          # Core Riverpod providers
│   ├── themes/             # App theming
│   ├── widgets/            # Reusable widgets
│   └── extensions/         # Utility extensions
├── features/               # Feature modules
│   ├── auth/              # Authentication flow
│   ├── dreams/            # Dream CRUD operations
│   ├── profile/           # User profile
│   ├── settings/          # App settings
│   ├── feedback/          # User feedback
│   ├── about/             # About page
│   └── shared/            # Shared feature components
├── main.dart              # App entry point
└── routes.dart            # Centralized routing
```

Each feature follows a layered structure:
- `data/` - Models and repositories
- `presentation/` - Pages, widgets, and UI
- `providers/` - Riverpod state management providers
- `domain/` - Business logic (if needed)

### State Management with Riverpod

- **Providers:** Located in feature-specific `providers/` directories
- **Core providers:** Defined in `core/providers/core_providers.dart`
- **Pattern:** Use `StateNotifierProvider` for mutable state, `Provider` for immutable dependencies

### Authentication Flow

1. **Token Storage:** `AuthService` uses Flutter Secure Storage
   - Access token: `TOCKENKEY_JWT` (note: typo is intentional, don't change)
   - Refresh token: `REFRESH_TOCKENKEY_JWT`
   - User data: `USER_DATA_KEY`

2. **Token Refresh:** Handled automatically by `TokenInterceptor`
   - On 401 responses, attempts token refresh
   - On refresh failure, triggers `forceLogout()` via `authProvider`
   - Throws `ForceLogoutInitiatedException` to abort request

3. **API Client:** `ApiClient` wraps HTTP client with:
   - Automatic auth header injection
   - Token refresh on 401
   - Rate limiting (100 requests/hour)
   - Request retry with new token

### Network Layer

**ApiClient** (`lib/core/network/api_client.dart`):
- Methods: `get()`, `post()`, `put()`, `delete()`
- All methods accept optional `requireAuth` parameter (default: true)
- Rate limiting: 100 requests per hour window
- Throws `RateLimitExceededException` when limit exceeded

**TokenInterceptor** (`lib/core/network/token_interceptor.dart`):
- Adds Bearer token to requests
- Intercepts 401 responses and refreshes token
- Uses `Ref` to access `authProvider` for force logout

### Repository Pattern

**Example: DreamRepository**
- In-memory caching with 5-minute TTL
- Methods: `getDreams()`, `getDreamById()`, `addDream()`, `updateDream()`, `deleteDream()`
- Cache invalidation on mutations
- Fallback to cache on network errors

### Routing

Centralized in `lib/routes.dart`:
- Named routes defined as constants in `AppRoutes`
- All routes registered in `getRoutes()` map
- Initial route: `AuthWrapper` handles auth state

## Backend Integration

The backend API URL is configured via `.env` file (`API_URL`).

### Key Endpoints

**Authentication:**
- `POST /auth/login` - Email/password login
- `POST /auth/register` - User registration
- `POST /auth/google` - Google Sign-in
- `POST /auth/refresh` - Refresh access token

**Dreams:**
- `GET /dreams/` - Fetch all dreams
- `POST /dreams/` - Create dream (returns AI interpretation)
- `PUT /dreams/{id}/` - Update dream
- `DELETE /dreams/{id}/` - Delete dream

**Dream Explorer** (AI-powered features - see `FRONTEND_INTEGRATION_GUIDE.md`):
- `POST /dream-explorer/ask` - Conversational Q&A
- `POST /dream-explorer/search` - Semantic search
- `GET /dream-explorer/similar/{id}` - Find similar dreams
- `POST /dream-explorer/patterns` - Pattern analysis
- `POST /dream-explorer/compare` - Compare two dreams

## Coding Guidelines

**From `rules.md`:**
- Write minimum code required
- No sweeping changes or unrelated edits
- Make code precise, modular, testable
- Don't break existing functionality
- **Log all changes** to `ai_changes_log.md` with date, time, filename, and description

### Error Handling

**API Error Format:**
- Backend returns structured error in `detail` field
- `ApiClient._processResponse()` handles Pydantic validation errors
- Extract error message from `detail` (string or list of validation errors)

### Common Patterns

**Adding a new feature:**
1. Create feature directory under `lib/features/`
2. Add data layer: models, repositories
3. Add presentation layer: pages, widgets
4. Create Riverpod providers
5. Register routes in `routes.dart`
6. Use `ApiClient` from `core/providers/core_providers.dart`

**Making authenticated API calls:**
```dart
final apiClient = ref.read(apiClientProvider);
final response = await apiClient.get('/endpoint');
// requireAuth defaults to true
```

**Using secure storage:**
```dart
await AuthService.setToken(token);
final token = await AuthService.getToken();
await AuthService.deleteToken();
```

## Important Notes

- **Security:** Never commit `.env` file or expose API keys
- **Token typo:** Storage keys have typo "TOCKEN" - don't fix it (backward compatibility)
- **Dark theme:** App uses dark theme by default (`AppTheme.darkTheme`)
- **Google Auth:** Requires platform-specific setup (see `GOOGLE_SIGNIN_SETUP.md`)
- **Rate limiting:** Client-side rate limiting prevents API abuse (100 req/hour)
- **Caching:** Repositories implement in-memory caching - be aware when debugging

## Environment Variables

Required in `.env` file in `dream_journal_app/` directory:
- `API_URL` - Backend API base URL
- `GOOGLE_CLIENT_ID` - Google OAuth client ID

## Testing

Tests are located in `dream_journal_app/test/`. Run with `flutter test`.

## Version

Current version: 1.0.1+5 (defined in `pubspec.yaml`)
