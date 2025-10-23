# Dream Explorer Feature - Implementation Plan

## Overview

Implement a conversational AI-powered Dream Explorer feature that allows users to interact with their dream history through natural language, semantic search, pattern analysis, and comparison.

**Total New UI Pages: 1**

- Dream Explorer Page (main tabbed interface with 5 tabs)

**UI Structure:**

```
DreamExplorerPage (with TabBar - Option A)
├── Tab 1: Chat (Conversational Q&A) - DEFAULT
├── Tab 2: Search (Semantic Search)
├── Tab 3: Patterns (Pattern Analysis)
├── Tab 4: Compare (Dream Comparison)
└── Tab 5: Similar (Find Similar Dreams)
```

**Additional Components:**

- 1 modal widget (Dream Selector for comparison feature)
- 7 reusable widgets (chat bubbles, cards, indicators, etc.)

---

## File Structure

```
lib/features/dream_explorer/
├── data/
│   ├── models/
│   │   ├── dream_summary_model.dart
│   │   ├── chat_message_model.dart
│   │   ├── dream_explorer_response_model.dart
│   │   ├── similar_dreams_response_model.dart
│   │   ├── pattern_response_model.dart
│   │   └── compare_dreams_response_model.dart
│   └── repositories/
│       └── dream_explorer_repository.dart
├── providers/
│   ├── dream_explorer_repository_provider.dart
│   ├── conversation_state_provider.dart
│   ├── search_state_provider.dart
│   ├── pattern_analysis_provider.dart
│   ├── comparison_state_provider.dart
│   └── similar_dreams_provider.dart
└── presentation/
    ├── pages/
    │   └── dream_explorer_page.dart (main page with TabBar)
    └── widgets/
        ├── tabs/
        │   ├── chat_tab.dart
        │   ├── search_tab.dart
        │   ├── patterns_tab.dart
        │   ├── compare_tab.dart
        │   └── similar_tab.dart
        ├── dream_summary_card.dart
        ├── chat_message_bubble.dart
        ├── relevance_score_indicator.dart
        ├── loading_chat_indicator.dart
        ├── error_message_widget.dart
        ├── dream_explorer_app_bar.dart
        ├── filter_chips_widget.dart
        └── dream_selector_modal.dart
```

---

## Phase 1: Data Layer Setup

### 1.1 Create Data Models

**Location:** `lib/features/dream_explorer/data/models/`

**Files to create:**

1. **dream_summary_model.dart**

   - Model for dream summaries returned from API
   - Fields: `dream_id`, `title`, `date`, `relevance_score`
   - Include `fromJson()` and `toJson()` methods

2. **chat_message_model.dart**

   - Model for chat history
   - Fields: `role` (user/assistant), `content`
   - Include `fromJson()` and `toJson()` methods

3. **dream_explorer_response_model.dart**

   - Model for conversational Q&A responses
   - Fields: `answer`, `relevant_dreams` (List<DreamSummary>), `chat_history`
   - Include `fromJson()` method

4. **similar_dreams_response_model.dart**

   - Model for similar dreams and search results
   - Fields: `dreams` (List<DreamSummary>), `total_found`
   - Include `fromJson()` method

5. **pattern_response_model.dart**

   - Model for pattern analysis
   - Fields: `pattern_analysis`, `relevant_dreams` (List<DreamSummary>)
   - Include `fromJson()` method

6. **compare_dreams_response_model.dart**
   - Model for dream comparison
   - Fields: `comparison` (string with detailed analysis)
   - Include `fromJson()` method

### 1.2 Create Repository

**Location:** `lib/features/dream_explorer/data/repositories/`

**File: dream_explorer_repository.dart**

Implement methods:

- `askQuestion(String question, List<ChatMessage> chatHistory, {int topK = 5})` � Returns `DreamExplorerResponse`
- `searchDreams(String query, {int topK = 5, DateTime? startDate, DateTime? endDate, List<String>? emotionTags})` � Returns `SimilarDreamsResponse`
- `findSimilarDreams(int dreamId, {int topK = 5})` � Returns `SimilarDreamsResponse`
- `findPatterns(String patternQuery, {int topK = 10})` � Returns `PatternResponse`
- `compareDreams(int dreamId1, int dreamId2)` � Returns `CompareDreamsResponse`
- `checkHealth()` � Returns health status

**Implementation notes:**

- Use `ApiClient` from `core/providers/core_providers.dart`
- All endpoints require authentication (requireAuth: true)
- Handle rate limiting errors gracefully
- Implement error handling for 401, 404, 422, 429, 500, 503
- Add request/response logging for debugging

---

## Phase 2: State Management

### 2.1 Create Providers

**Location:** `lib/features/dream_explorer/providers/`

**Files to create:**

1. **dream_explorer_repository_provider.dart**

   - Provider for `DreamExplorerRepository`
   - Depends on `apiClientProvider`

2. **conversation_state_provider.dart**

   - StateNotifier for managing conversation state
   - State fields:
     - `chatHistory` (List<ChatMessage>)
     - `isLoading` (bool)
     - `error` (String?)
     - `relevantDreams` (List<DreamSummary>)
   - Methods:
     - `askQuestion(String question, {int topK = 5})`
     - `clearConversation()`
     - `resetError()`

3. **search_state_provider.dart**

   - StateNotifier for semantic search
   - State fields:
     - `searchResults` (List<DreamSummary>)
     - `isLoading` (bool)
     - `error` (String?)
     - `totalFound` (int)
     - `currentQuery` (String?)
   - Methods:
     - `searchDreams(String query, {filters})`
     - `clearSearch()`

4. **pattern_analysis_provider.dart**

   - StateNotifier for pattern analysis
   - State fields:
     - `analysis` (String?)
     - `relevantDreams` (List<DreamSummary>)
     - `isLoading` (bool)
     - `error` (String?)
   - Methods:
     - `analyzePatterns(String query, {int topK = 10})`
     - `clearAnalysis()`

5. **comparison_state_provider.dart**

   - StateNotifier for dream comparison
   - State fields:
     - `comparison` (String?)
     - `selectedDream1Id` (int?)
     - `selectedDream2Id` (int?)
     - `isLoading` (bool)
     - `error` (String?)
   - Methods:
     - `compareDreams(int dreamId1, int dreamId2)`
     - `clearComparison()`

6. **similar_dreams_provider.dart**
   - StateNotifier for finding similar dreams
   - State fields:
     - `similarDreams` (List<DreamSummary>)
     - `isLoading` (bool)
     - `error` (String?)
   - Methods:
     - `findSimilar(int dreamId, {int topK = 5})`
     - `clearResults()`

---

## Phase 3: UI Components - Reusable Widgets

### 3.1 Create Shared Widgets

**Location:** `lib/features/dream_explorer/presentation/widgets/`

**Files to create:**

1. **dream_summary_card.dart**

   - Displays a dream summary with relevance score
   - Shows: title, date, relevance score (visual indicator)
   - Tappable to navigate to dream detail
   - Use card design consistent with app theme

2. **chat_message_bubble.dart**

   - Displays a single chat message
   - Different styling for user vs assistant messages
   - User messages: right-aligned, accent color
   - Assistant messages: left-aligned, card color
   - Include timestamp

3. **relevance_score_indicator.dart**

   - Visual indicator for relevance score (0.0 - 1.0)
   - Options: progress bar, stars, or percentage badge
   - Color-coded (high: green, medium: yellow, low: gray)

4. **loading_chat_indicator.dart**

   - Animated loading indicator for chat responses
   - Typing animation or pulse effect

5. **error_message_widget.dart**

   - Displays error messages with retry option
   - Different styling for network errors vs validation errors
   - Include error icon and descriptive message

6. **dream_explorer_app_bar.dart**

   - Custom app bar for Dream Explorer pages
   - Include gradient or special styling
   - Back button and page title

7. **filter_chips_widget.dart**
   - Horizontal scrollable filter chips
   - For emotion tags and date range selection
   - Multi-select capability

---

## Phase 4: Main Dream Explorer Page with Tab Navigation

### 4.1 Dream Explorer Main Page

**Location:** `lib/features/dream_explorer/presentation/pages/`

**File: dream_explorer_page.dart**

**Main Structure:**

- App bar with title "Dream Explorer"
- Tab bar with 5 tabs:
  1. **Chat** (DEFAULT - index 0) - Conversational Q&A interface
  2. **Search** (index 1) - Semantic dream search
  3. **Patterns** (index 2) - Pattern analysis
  4. **Compare** (index 3) - Compare two dreams
  5. **Similar** (index 4) - Find similar dreams
- TabBarView with 5 corresponding tab views

**Implementation:**

- Use `DefaultTabController` with `initialIndex: 0` (Chat tab)
- **Chat tab is the first and default tab** - users land directly in the conversational interface
- No splash screen, no feature selection - ready to chat immediately
- Maintain state for each tab independently
- Use `AutomaticKeepAliveClientMixin` in each tab widget to preserve tab state when switching
- Support optional navigation arguments to open specific tabs (see Phase 9.2)

**Key Point:**
When the user opens Dream Explorer, they immediately see the chat interface with:

- Chat history (if any)
- Text input field ready for questions
- Tab bar at the top to switch to other features

### 4.2 Chat Tab (Conversational Q&A)

**Location:** `lib/features/dream_explorer/presentation/widgets/tabs/`

**File: chat_tab.dart**

**Layout:**

- Chat message list (scrollable)
  - Display chat history using `ChatMessageBubble`
  - Show relevant dreams below each assistant response
  - Auto-scroll to bottom on new messages
- Input section at bottom:
  - Text field for question input (3-500 chars validation)
  - Send button
  - Character counter
  - Loading indicator during API call
- Clear conversation button in app bar (when on this tab)

**Features:**

- Maintain conversation context
- Display relevant dreams with relevance scores
- Tap dream card to view full dream details
- Pull-to-refresh to clear conversation
- Error handling with retry option

**State Management:**

- Use `conversationStateProvider`
- Handle loading states
- Display errors inline

---

## Phase 5: Search Tab

### 5.1 Search Tab Widget

**Location:** `lib/features/dream_explorer/presentation/widgets/tabs/`

**File: search_tab.dart**

**Layout:**

- Search bar at top:
  - Text field with search icon
  - Clear button
  - Search button or search on enter
- Filters section (collapsible):
  - Date range picker (start and end date)
  - Emotion tags (multi-select chips)
  - Top K slider (1-20, default 5)
- Results section:
  - List of `DreamSummaryCard` widgets
  - Show relevance scores
  - Empty state when no results
  - Total found count
- FAB for clearing filters

**Features:**

- Real-time search (debounced)
- Filter dreams by date range and emotions
- Display results sorted by relevance
- Tap result to view full dream
- Persistence of search query during session

**State Management:**

- Use `searchStateProvider`
- Handle loading and error states
- Clear filters functionality

---

## Phase 6: Pattern Analysis Tab

### 6.1 Patterns Tab Widget

**Location:** `lib/features/dream_explorer/presentation/widgets/tabs/`

**File: patterns_tab.dart**

**Layout:**

- Input section:
  - Text field for pattern query (3-200 chars)
  - Examples section (expandable):
    - "recurring nightmares about being chased"
    - "dreams about flying"
    - "water-related dreams"
  - Top K slider (1-50, default 10)
  - Analyze button
- Results section:
  - Analysis text (expandable card)
  - Relevant dreams list
  - Export/share analysis option

**Features:**

- AI-generated pattern analysis
- Display relevant dreams supporting the pattern
- Copy analysis to clipboard
- Share analysis text
- Save interesting patterns to favorites (future enhancement)

**State Management:**

- Use `patternAnalysisProvider`
- Handle loading states (show skeleton)
- Error handling with retry

---

## Phase 7: Dream Comparison Tab

### 7.1 Compare Tab Widget

**Location:** `lib/features/dream_explorer/presentation/widgets/tabs/`

**File: compare_tab.dart**

**Layout:**

- Selection section:
  - Two dream selector cards (side by side or stacked)
  - "Select Dream 1" button
  - "Select Dream 2" button
  - Show selected dream titles and dates
- Compare button (enabled only when both selected)
- Results section:
  - Comparison analysis (formatted with sections)
  - Similarities section
  - Differences section
  - Insights section
  - Share comparison option

**Features:**

- Dream selection via search/list modal
- Side-by-side dream preview
- Formatted comparison output
- Copy/share comparison
- Clear selection button

**State Management:**

- Use `comparisonStateProvider`
- Handle dream selection state
- Loading and error states

### 7.2 Dream Selector Modal

**Location:** `lib/features/dream_explorer/presentation/widgets/`

**File: dream_selector_modal.dart**

**Features:**

- Bottom sheet or full-screen modal
- Search bar to filter dreams
- Scrollable list of user's dreams
- Show dream title and date
- Select button for each dream

---

## Phase 8: Similar Dreams Tab

### 8.1 Similar Tab Widget

**Location:** `lib/features/dream_explorer/presentation/widgets/tabs/`

**File: similar_tab.dart**

**Layout:**

- Dream selector section (if no dream selected yet)
- Source dream card (highlighted, once selected)
- Top K selector (1-20, default 5)
- Similar dreams list
- Empty state when no similar dreams found

**Features:**

- Accept dream ID as parameter (from navigation)
- Display source dream at top
- Show similar dreams with relevance scores
- Tap to view full dream
- "Find similar" action can be triggered from any dream detail page

**Alternative Implementation:**

- Integrate as a section within existing dream detail page
- "Similar Dreams" expandable section
- Lazy load on demand

**State Management:**

- Use `similarDreamsProvider`
- Handle loading and error states

---

## Phase 9: Navigation & Routing

### 9.1 Update Routes

**Location:** `lib/routes.dart`

**Add new route:**

```dart
static const String dreamExplorer = '/dream-explorer';
```

**Register route in `getRoutes()`:**

- Map route to `DreamExplorerPage`
- Optional: Support initial tab parameter (e.g., `/dream-explorer?tab=search`)

**Example route registration:**

```dart
AppRoutes.dreamExplorer: (context) => const DreamExplorerPage(),
```

### 9.2 Default Tab Configuration

**Implementation in Phase 4.1**

The `DreamExplorerPage` opens with **Chat tab as the default** (index 0):

**TabController Setup:**

```dart
DefaultTabController(
  length: 5,
  initialIndex: 0, // Chat tab is DEFAULT
  child: Scaffold(
    appBar: AppBar(
      title: Text('Dream Explorer'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.chat), text: 'Chat'),      // Index 0 - DEFAULT
          Tab(icon: Icon(Icons.search), text: 'Search'),   // Index 1
          Tab(icon: Icon(Icons.pattern), text: 'Patterns'), // Index 2
          Tab(icon: Icon(Icons.compare), text: 'Compare'), // Index 3
          Tab(icon: Icon(Icons.similarity), text: 'Similar'), // Index 4
        ],
      ),
    ),
    body: TabBarView(
      children: [
        ChatTab(),      // First tab - User lands here by default
        SearchTab(),
        PatternsTab(),
        CompareTab(),
        SimilarTab(),
      ],
    ),
  ),
)
```

**User Experience:**

- When user opens Dream Explorer, they **immediately see the chat interface**
- Chat input field is ready for questions
- No intermediate screen or feature selection needed
- Users can switch to other tabs as needed

**Tab State Preservation:**

- Use `AutomaticKeepAliveClientMixin` in each tab widget
- Preserves state when switching between tabs
- Chat history, search results, etc., remain intact when navigating back

**Deep Linking (Optional):**

- Support opening specific tabs via navigation arguments
- Example: `Navigator.pushNamed(context, AppRoutes.dreamExplorer, arguments: {'initialTab': 2})` to open Patterns tab
- If no argument provided, defaults to Chat tab (index 0)

### 9.3 Add Entry Point to Dream Explorer

**Location:** Main dreams list or home page

**Recommended Options:**

1. **Add to bottom navigation bar** - Add "Explore" as a new tab
2. **Add FAB on dreams list page** - Opens Dream Explorer (Chat tab by default)
3. **Add menu item in app drawer** - "Dream Explorer" option
4. **Add button in app bar** - Icon button with sparkle/search icon

**Implementation Example (FAB on Dreams List):**

```dart
floatingActionButton: FloatingActionButton(
  onPressed: () => Navigator.pushNamed(context, AppRoutes.dreamExplorer),
  child: Icon(Icons.auto_awesome), // or Icons.explore
  tooltip: 'Explore Dreams',
),
```

### 9.4 Navigation from Other Pages

**Enable navigation to specific tabs:**

1. **From Dream Detail Page:**

   - "Find Similar" button → Opens Dream Explorer on Similar tab with dream pre-selected

2. **From Dreams List:**
   - Search icon → Opens Dream Explorer on Search tab
   - Pattern discovery prompt → Opens Dream Explorer on Patterns tab

**Implementation:**

```dart
// Navigate to specific tab with data
Navigator.pushNamed(
  context,
  AppRoutes.dreamExplorer,
  arguments: {
    'initialTab': 4, // Similar tab
    'dreamId': dreamId,
  },
);
```

---

## Phase 10: Error Handling & Edge Cases

### 10.1 Rate Limiting

**Implementation:**

- Detect 429 errors in repository
- Show user-friendly message: "Too many requests. Please wait a moment."
- Implement exponential backoff for retries
- Display countdown timer before retry enabled

### 10.2 Authentication Errors

- Handle 401 errors (already handled by TokenInterceptor)
- Show message if token refresh fails
- Redirect to login if needed

### 10.3 Validation Errors

- Handle 422 errors from backend
- Display field-specific error messages
- Show input constraints (e.g., "Question must be 3-500 characters")

### 10.4 Network Errors

- Handle offline scenarios
- Show retry button
- Cache last successful response (optional)

### 10.5 Empty States

- No dreams found in search
- No similar dreams available
- No patterns detected
- Empty conversation history

### 10.6 Input Validation

**Client-side validation before API calls:**

- Question length: 3-500 characters
- Pattern query: 3-200 characters
- Top K: 1-20 for most endpoints, 1-50 for patterns
- Date range: start date < end date

---

## Phase 11: Testing

### 11.1 Unit Tests

**Location:** `test/features/dream_explorer/`

**Test coverage:**

1. **Models:**

   - Test `fromJson()` and `toJson()` methods
   - Test null handling
   - Test date parsing

2. **Repository:**

   - Mock API client responses
   - Test successful API calls
   - Test error handling (401, 404, 422, 429, 500)
   - Test rate limiting logic

3. **Providers:**
   - Test state transitions
   - Test loading states
   - Test error states
   - Test conversation history management
   - Test search filter logic

### 11.2 Widget Tests

**Test UI components:**

- ChatMessageBubble rendering
- DreamSummaryCard rendering and tap handling
- Input validation
- Error message display
- Loading indicators

### 11.3 Integration Tests

**End-to-end scenarios:**

- Complete conversation flow
- Search with filters
- Pattern analysis flow
- Dream comparison flow
- Navigation between features

---

## Phase 12: Polish & Enhancements

### 12.1 UI/UX Improvements

- Add animations:
  - Chat message fade-in
  - Loading skeleton for results
  - Page transitions
- Add haptic feedback on interactions
- Implement pull-to-refresh where appropriate
- Add empty state illustrations
- Smooth scrolling animations

### 12.2 User Feedback

- Loading indicators with progress messages
- Success messages after actions

---

---

## Implementation Order (Recommended)

1. **Start with Data Layer** (Phase 1)

   - Create all models
   - Implement repository
   - Test repository methods

2. **Setup State Management** (Phase 2)

   - Create all providers
   - Test provider logic

3. **Build Reusable Widgets** (Phase 3)

   - Create shared components
   - Test in isolation

4. **Create Main Dream Explorer Page with Tabs** (Phase 4.1)

   - Create `DreamExplorerPage` with TabBar
   - Setup 5 tabs: Chat, Search, Patterns, Compare, Similar
   - Implement tab state preservation

5. **Implement Tabs One at a Time:**

   - Start with **Chat Tab** (Phase 4.2) - Core feature and default tab
   - Then **Search Tab** (Phase 5) - Common use case
   - Then **Similar Tab** (Phase 8) - Simpler feature
   - Then **Patterns Tab** (Phase 6) - Medium complexity
   - Finally **Compare Tab** (Phase 7) - Most complex

6. **Setup Navigation & Entry Points** (Phase 9)

   - Register Dream Explorer route
   - Add entry point (FAB, drawer, or bottom nav)
   - Implement deep linking to specific tabs

7. **Handle Edge Cases** (Phase 10)

   - Implement error handling
   - Add validation

8. **Write Tests** (Phase 11)

   - Unit tests
   - Widget tests
   - Integration tests

9. **Polish** (Phase 12)

   - UI/UX improvements
   - Animations
   - Accessibility

---

## Dependencies to Add

Check if these packages are needed:

- `intl` - For date formatting (likely already included)
- `url_launcher` - For sharing (if not already included)
- `share_plus` - For native sharing
- `flutter_markdown` - If API returns markdown in analysis

---

## Notes

- All API endpoints require JWT authentication
- Rate limits vary by endpoint (see FRONTEND_INTEGRATION_GUIDE.md)
- Semantic search works by meaning, not keyword matching
- Chat history maintains conversation context
- Dreams are automatically embedded on creation/update
- Users can only access their own dreams
- Use ISO 8601 date format: "2024-01-15T10:30:00"

---

## Success Criteria

- [ ] Users can have natural conversations about their dreams
- [ ] Search accurately finds dreams by meaning
- [ ] Pattern analysis provides valuable insights
- [ ] Dream comparison reveals meaningful connections
- [ ] Similar dreams feature works reliably
- [ ] All error cases handled gracefully
- [ ] Rate limiting respected and communicated clearly
- [ ] UI is intuitive and responsive
- [ ] Feature integrates seamlessly with existing app
- [ ] All tests passing
- [ ] Code follows project guidelines (rules.md)
- [ ] Changes logged in ai_changes_log.md
