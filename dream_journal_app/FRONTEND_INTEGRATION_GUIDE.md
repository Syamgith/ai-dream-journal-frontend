Feature Idea: The "Dream Explorer" — A Conversational Memory
Instead of just getting a one-time interpretation, this feature would allow users to have a conversation with their entire dream history. They could ask follow-up questions and explore patterns over time.
User Experience: Imagine a chat interface in your app where the user could ask questions like:
"What do my dreams about flying usually mean?"
"Have I ever dreamt about my childhood friend, Sarah, before?"

# Dream Explorer - Backend API Reference

---

## Overview

**Dream Explorer** enables conversational interaction with dream history using AI-powered semantic search and analysis.

### Core Capabilities

- Ask natural language questions about dream history
- Search dreams by meaning (semantic search)
- Discover recurring patterns and themes
- Compare dreams side-by-side
- Find similar dreams automatically

---

## Authentication

All endpoints require JWT authentication.

**Header:**

```
Authorization: Bearer <access_token>
```

---

## API Endpoints

### 1. Ask Question (Conversational Q&A)

Ask natural language questions with conversation context.

**Endpoint:** `POST /dream-explorer/ask`
**Rate Limit:** 10/minute

**Request:**

```json
{
  "question": "What do my dreams about flying usually mean?",
  "chat_history": [],
  "top_k": 5
}
```

**Response:**

```json
{
  "answer": "Based on your dream history, flying dreams appear 7 times...",
  "relevant_dreams": [
    {
      "dream_id": 123,
      "title": "Flying Over Mountains",
      "date": "2024-01-15T10:30:00",
      "relevance_score": 0.87
    }
  ],
  "chat_history": [
    {
      "role": "user",
      "content": "What do my dreams about flying usually mean?"
    },
    { "role": "assistant", "content": "Based on your dream history..." }
  ]
}
```

**Example cURL:**

```bash
curl -X POST "http://localhost:8000/dream-explorer/ask" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What do my dreams about flying mean?",
    "chat_history": [],
    "top_k": 5
  }'
```

---

### 2. Search Dreams

Semantic search across dream history with optional filters.

**Endpoint:** `POST /dream-explorer/search`
**Rate Limit:** 20/minute

**Request:**

```json
{
  "query": "dreams about water and oceans",
  "top_k": 5,
  "start_date": "2024-01-01T00:00:00",
  "end_date": "2024-12-31T23:59:59",
  "emotion_tags": ["calm", "peaceful"]
}
```

**Response:**

```json
{
  "dreams": [
    {
      "dream_id": 145,
      "title": "Swimming in Ocean",
      "date": "2024-03-10T09:00:00",
      "relevance_score": 0.91
    }
  ],
  "total_found": 1
}
```

**Example cURL:**

```bash
curl -X POST "http://localhost:8000/dream-explorer/search" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "dreams about water",
    "top_k": 5
  }'
```

---

### 3. Find Similar Dreams

Find dreams similar to a specific dream by ID.

**Endpoint:** `GET /dream-explorer/similar/{dream_id}`
**Rate Limit:** 30/minute

**Query Parameters:**

- `dream_id` (path): Dream ID to compare
- `top_k` (optional): Number of results (default: 5)

**Request:**

```
GET /dream-explorer/similar/123?top_k=5
```

**Response:**

```json
{
  "dreams": [
    {
      "dream_id": 125,
      "title": "Flying Through City",
      "date": "2024-01-20T10:00:00",
      "relevance_score": 0.89
    }
  ],
  "total_found": 1
}
```

**Example cURL:**

```bash
curl -X GET "http://localhost:8000/dream-explorer/similar/123?top_k=5" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 4. Find Patterns

Analyze dreams to identify recurring patterns and themes.

**Endpoint:** `POST /dream-explorer/patterns`
**Rate Limit:** 5/minute

**Request:**

```json
{
  "pattern_query": "recurring nightmares about being chased",
  "top_k": 10
}
```

**Response:**

```json
{
  "pattern_analysis": "Analyzing your dreams, I've identified a recurring pattern of chase-related nightmares appearing 8 times over the past 6 months. These dreams typically occur during high-stress periods...",
  "relevant_dreams": [
    {
      "dream_id": 156,
      "title": "Running From Shadow",
      "date": "2024-04-05T03:00:00",
      "relevance_score": 0.94
    }
  ]
}
```

**Example cURL:**

```bash
curl -X POST "http://localhost:8000/dream-explorer/patterns" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pattern_query": "nightmares about being chased",
    "top_k": 10
  }'
```

---

### 5. Compare Dreams

Compare two dreams and get AI insights about their connections.

**Endpoint:** `POST /dream-explorer/compare`
**Rate Limit:** 15/minute

**Request:**

```json
{
  "dream_id_1": 123,
  "dream_id_2": 456
}
```

**Response:**

```json
{
  "comparison": "Comparing these two dreams reveals interesting connections:\n\nSimilarities:\n- Both feature water imagery (ocean vs. river)\n- Themes of journey and exploration\n\nDifferences:\n- Dream 1 focuses on vastness, Dream 2 on flow\n\nInsights:\nThe shift from ocean to river may represent finding your path..."
}
```

**Example cURL:**

```bash
curl -X POST "http://localhost:8000/dream-explorer/compare" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "dream_id_1": 123,
    "dream_id_2": 456
  }'
```

---

### 6. Health Check

Check if Dream Explorer service is operational.

**Endpoint:** `GET /dream-explorer/health`
**Rate Limit:** None

**Response:**

```json
{
  "status": "healthy",
  "service": "Dream Explorer",
  "message": "All systems operational"
}
```

---

## Data Types

### Request Schemas

#### DreamExplorerQuery

```typescript
{
  question: string;          // 3-500 chars, required
  chat_history?: Array<{     // optional, default: []
    role: string;
    content: string;
  }>;
  top_k?: number;           // 1-20, optional
}
```

#### SimilarDreamsRequest

```typescript
{
  query?: string;           // 3-500 chars
  top_k?: number;          // 1-20
  start_date?: datetime;   // ISO 8601 format
  end_date?: datetime;     // ISO 8601 format
  emotion_tags?: string[]; // array of emotion strings
}
```

#### PatternSearchRequest

```typescript
{
  pattern_query: string;   // 3-200 chars, required
  top_k?: number;         // 1-50
}
```

#### CompareDreamsRequest

```typescript
{
  dream_id_1: number; // required
  dream_id_2: number; // required
}
```

### Response Schemas

#### DreamSummary

```typescript
{
  dream_id: number;
  title: string;
  date: string; // ISO 8601 or null
  relevance_score: number; // 0.0 - 1.0
}
```

#### DreamExplorerResponse

```typescript
{
  answer: string;
  relevant_dreams: DreamSummary[];
  chat_history: Array<{
    role: string;
    content: string;
  }>;
}
```

#### SimilarDreamsResponse

```typescript
{
  dreams: DreamSummary[];
  total_found: number;
}
```

#### PatternSearchResponse

```typescript
{
  pattern_analysis: string;
  relevant_dreams: DreamSummary[];
}
```

#### CompareDreamsResponse

```typescript
{
  comparison: string;
}
```

---

## Error Responses

### HTTP Status Codes

| Code | Meaning             | Description                          |
| ---- | ------------------- | ------------------------------------ |
| 200  | Success             | Request completed successfully       |
| 401  | Unauthorized        | Invalid or missing JWT token         |
| 404  | Not Found           | Dream not found                      |
| 422  | Validation Error    | Invalid request parameters           |
| 429  | Rate Limited        | Too many requests, retry after delay |
| 500  | Server Error        | Internal server error                |
| 503  | Service Unavailable | Service temporarily down             |

### Error Format

```json
{
  "detail": "Error message"
}
```

### Rate Limit Error

```json
{
  "detail": "Rate limit exceeded"
}
```

---

## Rate Limits Summary

| Endpoint    | Limit     | Reason                 |
| ----------- | --------- | ---------------------- |
| `/ask`      | 10/minute | AI generation cost     |
| `/search`   | 20/minute | Vector search overhead |
| `/patterns` | 5/minute  | Heavy analysis         |
| `/compare`  | 15/minute | Moderate AI usage      |
| `/similar`  | 30/minute | Fast lookup            |
| `/health`   | No limit  | Monitoring             |

---

## WebSocket Endpoints (Optional)

For real-time streaming responses:

**Endpoints:**

- `WS /dream-explorer/ws/ask/{session_id}?token={jwt_token}`
- `WS /dream-explorer/ws/search/{session_id}?token={jwt_token}`

**Message Types:**

- `status` - Progress updates
- `chunk` - Streamed content
- `complete` - Final response

---

## Notes

1. **Authentication**: All endpoints require valid JWT token in Authorization header
2. **Dates**: Use ISO 8601 format (e.g., "2024-01-15T10:30:00")
3. **Semantic Search**: Searches by meaning, not exact word matches
4. **Chat History**: Maintains conversation context for follow-up questions
5. **Embeddings**: Dreams automatically embedded on creation/update
6. **User Isolation**: Users only access their own dreams

---
