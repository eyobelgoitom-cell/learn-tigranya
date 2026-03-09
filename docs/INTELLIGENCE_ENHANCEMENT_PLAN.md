# Fidel Learn — Intelligence & Analytics Enhancement Plan

**Goal:** Make the app **think**, **understand**, **search**, and **collect** data so it can adapt and personalize the learning experience.

---

## Current State vs. Target

| Capability | Now | Target |
|------------|-----|--------|
| **Collect** | Lesson completed, basic quiz correct/incorrect | Granular events: every answer, flashcard flip, time spent, session context |
| **Search** | None | Search lessons, words, Fidel characters by transliteration, translation, or character |
| **Analyze** | Streak, daily goal, accuracy % | Weak areas, mastery per consonant group, optimal next lesson |
| **Think / Adapt** | Static "Continue" suggestion | Smart recommendations: what to review, when to introduce new content |

---

## Phase 1: Event Collection (Foundation)

**Why first:** You can't analyze or adapt without data. Collect rich events now; use them later.

### 1.1 Learning Events Table

```sql
-- supabase/migrations/YYYYMMDD_learning_events.sql
CREATE TABLE public.learning_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,  -- 'quiz_answer' | 'flashcard_review' | 'lesson_view' | 'lesson_complete' | 'audio_play'
    payload JSONB NOT NULL,   -- flexible: question_id, correct, item_id, duration_seconds, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_learning_events_user ON public.learning_events(user_id);
CREATE INDEX idx_learning_events_type ON public.learning_events(event_type);
CREATE INDEX idx_learning_events_created ON public.learning_events(created_at DESC);

-- RLS
ALTER TABLE public.learning_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert own events" ON public.learning_events FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can read own events" ON public.learning_events FOR SELECT USING (auth.uid() = user_id);
```

### 1.2 Event Payload Examples

| event_type | payload |
|------------|---------|
| `quiz_answer` | `{ "item_id": "char-1-3", "correct": true, "response_time_ms": 1200, "question_type": "alphabet" }` |
| `flashcard_review` | `{ "word_id": "uuid", "knew_it": true, "time_on_card_ms": 3000 }` |
| `lesson_view` | `{ "lesson_id": "lesson-1", "duration_seconds": 45 }` |
| `lesson_complete` | `{ "lesson_id": "lesson-1", "score": 0.9 }` |
| `audio_play` | `{ "item_id": "char-1-3", "item_type": "fidel" }` |

### 1.3 Swift: LearningEventService

```swift
// FidelLearn/Sources/Core/Analytics/LearningEventService.swift
protocol LearningEventServiceProtocol: Sendable {
    func record(_ event: LearningEvent) async
}

struct LearningEvent {
    let eventType: String
    let payload: [String: Any]
}
```

- Fire events from `QuizPracticeViewModel`, `FlashcardSession`, `AlphabetLessonViewModel`, etc.
- Batch and send when online; queue locally when offline (same pattern as `SyncProgressService`).

---

## Phase 2: Search

**Goal:** User can search lessons, words, and Fidel characters.

### 2.1 Search API

Options:

| Approach | Pros | Cons |
|----------|------|------|
| **Local search** | Offline, fast, no backend | Limited to bundled JSON |
| **Supabase full-text** | Scalable, supports future content | Requires network |
| **Hybrid** | Local first, Supabase when online | More code |

**Recommendation:** Start with **local search** over `LocalLessonService` data. Add Supabase full-text later if you add remote content.

### 2.2 Search Model

```swift
struct SearchResult: Identifiable {
    let id: String
    let type: SearchResultType  // .lesson | .word | .fidelCharacter
    let title: String
    let subtitle: String?
    let matchHighlight: String?  // e.g. "ሀ" in "ha"
}

enum SearchResultType {
    case lesson, word, fidelCharacter
}
```

### 2.3 Search UI

- Add a search bar to **LessonsView** and **PracticeView** (or a global search in the tab bar).
- Search by: lesson title, word (fidel/transliteration/translation), Fidel character or transliteration.
- Tapping a result navigates to the lesson, word detail, or character.

### 2.4 Implementation Sketch

```swift
// LessonServiceProtocol extension
func search(query: String, language: String) async -> [SearchResult]
```

- Normalize query (lowercase, trim).
- Filter `lessons`, `words`, `fidel_characters` where `title`, `fidel`, `transliteration`, or `translation` contains the query.
- Return `[SearchResult]` sorted by relevance (exact match > prefix > contains).

---

## Phase 3: Analysis & Insights

**Goal:** Understand *what* the user knows and *where* they struggle.

### 3.1 Derived Tables / Views (Supabase)

Use `learning_events` to compute:

| Insight | Source | Output |
|---------|--------|--------|
| **Weak Fidel characters** | `quiz_answer` where `item_type = 'fidel'` | Characters with low accuracy or high response time |
| **Weak vocabulary** | `quiz_answer` + `flashcard_review` for words | Words to review more |
| **Mastery by consonant group** | Aggregate by `consonant_group` from fidel_characters | e.g. "ሀ row: 80%, ለ row: 40%" |
| **Optimal study time** | `lesson_view` + `lesson_complete` timestamps | When user is most engaged |

### 3.2 Swift: InsightsService

```swift
protocol InsightsServiceProtocol: Sendable {
    func getWeakCharacters(limit: Int) async -> [FidelCharacter]
    func getWeakWords(limit: Int) async -> [Word]
    func getMasteryByConsonantGroup() async -> [(group: String, accuracy: Double)]
    func getRecommendedNextLesson() async -> Lesson?
}
```

- **Local-first:** Compute from `LocalProgressService` + local event queue when offline.
- **Remote:** Supabase Edge Function or Postgres view that queries `learning_events` + `user_progress`.

---

## Phase 4: Smart Recommendations

**Goal:** App "thinks" and suggests what to do next.

### 4.1 Recommendation Logic

| Scenario | Logic |
|----------|-------|
| **Continue lesson** | Next incomplete lesson in order (current behavior) |
| **Review weak items** | If any character/word accuracy < 60%, suggest "Review weak letters" or "Review weak words" |
| **Spaced repetition** | If flashcards have `next_review_at` in the past, suggest "Review flashcards" |
| **Daily goal** | If daily progress < goal, highlight "Complete 1 more lesson" |
| **Streak at risk** | If no activity today and it's late, push "Keep your streak!" |

### 4.2 HomeView Enhancement

Replace single "Continue" card with a **smart feed**:

```
1. [Urgent] Review 5 weak letters (60% accuracy)
2. [Continue] Lesson 3: ለ row
3. [Goal] 2/3 lessons today — one more!
4. [Streak] 7-day streak — don't break it!
```

Priority: urgent review > continue > daily goal > streak.

### 4.3 Implementation

- `RecommendationEngine` that takes `InsightsService` + `ProgressService` + `LearningEventService` (or local equivalents).
- Returns ordered `[Recommendation]` with `title`, `subtitle`, `action` (e.g. open lesson, open practice), `priority`.

---

## Phase 5: Understanding (Semantic Layer)

**Goal:** Group and reason about content, not just raw IDs.

### 5.1 Concept Mapping

- **Fidel:** Map each character to `consonant_group` + `vowel_order` (you already have this).
- **Words:** Tag by lesson/category (greetings, family, numbers, etc.).
- **Phrases:** (Future) Tag by use case.

### 5.2 Semantic Queries

- "Show me all characters in the ሀ row" → filter by `consonant_group`.
- "What greetings do I struggle with?" → filter `learning_events` by `lesson_id` in greetings + low accuracy.
- "Which vowel sounds do I mix up?" → group by `vowel_order`, compare accuracy.

### 5.3 Optional: Embeddings (Advanced)

For future: embed Fidel characters, words, or phrases and use semantic similarity (e.g. "similar to ሰላም"). Requires ML backend or Supabase pgvector. Defer to Phase 6+.

---

## Implementation Order

| Sprint | Focus | Deliverables |
|--------|-------|--------------|
| 1 | Event collection | `learning_events` table, `LearningEventService`, wire quiz/flashcard/lesson |
| 2 | Search | `search(query:)` on LocalLessonService, SearchView UI |
| 3 | Insights | `InsightsService` (local + optional remote), weak chars/words |
| 4 | Recommendations | `RecommendationEngine`, smart Home feed |
| 5 | Polish | Mastery views, semantic grouping in Progress tab |

---

## Privacy & Performance

- **Privacy:** All events are user-scoped (RLS). No PII in payload beyond `user_id`. Consider retention policy (e.g. delete events older than 1 year).
- **Performance:** Index `learning_events` by `user_id`, `event_type`, `created_at`. For heavy analytics, use materialized views or nightly batch jobs.
- **Offline:** Queue events locally; sync when online. Same pattern as progress sync.

---

## Quick Wins (Can Do Now)

1. **Extend `recordQuizAttempt`** — pass `itemId`, `questionType` so you can later analyze per-character/word.
2. **Add `recordFlashcardReview`** — to `ProgressServiceProtocol` and `LocalProgressService`.
3. **Search bar** — simple local filter on lessons + words in `LessonsView` (no new tables).
4. **"Review weak"** — compute from existing `quizStats` + which items were wrong (requires storing last N wrong answers in UserDefaults as a start).

---

## Summary

| Enhancement | Collect | Search | Analyze | Think |
|-------------|---------|--------|---------|-------|
| Learning events | ✅ | | | |
| Search | | ✅ | | |
| Insights | | | ✅ | |
| Recommendations | | | | ✅ |
| Semantic layer | | | ✅ | ✅ |

Start with **Phase 1 (events)** to unlock everything else. Then add **search** for discoverability and **insights + recommendations** for a smarter, more adaptive app.
