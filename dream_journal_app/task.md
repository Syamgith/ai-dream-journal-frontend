⏺ High-Level Plan for Markdown Formatting of AI Responses

I've explored your codebase and created a comprehensive plan. Here's what I
found and the approach:

Current State

AI responses are displayed as plain text in 7 key locations:

1. Dream interpretation - add_dream_page.dart & dream_details_page.dart
2. Chat messages - chat_message_bubble.dart
3. Pattern analysis - patterns_tab.dart
4. Dream comparison - compare_tab.dart
5. Search and similar dreams use card layouts (less critical for markdown)

All currently use simple Text widgets with basic styling (white text, size
14-15, line height 1.5).

Proposed Solution

Phase 1: Setup & Component Creation

- Evaluate Flutter markdown packages (flutter_markdown is the most popular,
  well-maintained option)
- Create a reusable MarkdownText widget in lib/core/widgets/ that:
  - Accepts markdown string content
  - Maintains current dark theme styling
  - Handles edge cases (null, empty strings)
  - Supports custom text styling to match your app's design

Phase 2: Implementation

- Replace all Text widgets displaying AI responses with the new MarkdownText
  widget
- Priority order:
  a. Chat messages (most interactive)
  b. Pattern & comparison analysis (long-form content benefits most)
  c. Dream interpretations

Phase 3: Testing

- Test with real AI responses containing:
  - Bold/italic text
  - Bullet lists
  - Numbered lists
  - Headings
  - Code blocks (if applicable)
