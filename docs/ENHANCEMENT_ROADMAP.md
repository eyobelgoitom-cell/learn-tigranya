# Fidel Learn — Enhancement Roadmap

**Focus areas:** UI/UX, Analytics, Smart Search, Intelligence

---

## 1. UI/UX Enhancements

### 1.1 Visual Polish (Quick Wins)

| Enhancement | Current | Target | Effort |
|-------------|---------|--------|--------|
| **Loading states** | Generic `ProgressView` | Skeleton loaders or branded shimmer | Low |
| **Empty states** | Basic icon + text | Illustrated empty states with CTA | Low |
| **Haptic feedback** | None | Success on correct answer, light tap on buttons | Low |
| **Card animations** | Static | Subtle entrance (staggered fade-in) | Low |
| **Streak celebration** | Plain number | Confetti or animation at milestones (7, 30 days) | Medium |

### 1.2 Home Screen

| Enhancement | Description |
|-------------|-------------|
| **Pull-to-refresh** | Refresh recommendations and stats |
| **Recommendation deep links** | "Review weak letters" → open Practice with weak-only quiz (not just switch tab) |
| **Streak at risk** | Visual urgency (pulsing flame, different color) when late in day with no activity |
| **Daily goal progress** | Animated ring or more prominent visual |
| **Onboarding tooltip** | First-time hint: "Tap a recommendation to start" |

### 1.3 Lessons & Practice

| Enhancement | Description |
|-------------|-------------|
| **Lesson progress bar** | Show % complete or "3/7 characters" in lesson header |
| **Quiz feedback** | Brief confetti or checkmark animation on correct; gentle shake on wrong |
| **Flashcard swipe** | Swipe right = Know it, left = Review later (in addition to buttons) |
| **Pronunciation practice** | Waveform or level meter when recording |
| **Dark mode polish** | Ensure all cards, borders, shadows look good in dark |

### 1.4 Progress Tab

| Enhancement | Description |
|-------------|-------------|
| **Mastery chart** | Bar chart or heatmap of consonant groups (from InsightsService) |
| **Weak areas callout** | "You struggle with ሀ row — tap to practice" |
| **Learning curve** | Simple line chart: words/lessons over time |
| **Achievement unlock animation** | Modal or toast when unlocking |

### 1.5 Accessibility

| Enhancement | Description |
|-------------|-------------|
| **Reduce motion** | Respect `UIAccessibility.isReduceMotionEnabled` |
| **Dynamic Type** | Test and fix layouts at larger text sizes |
| **VoiceOver** | Audit all screens; add hints for complex interactions |

---

## 2. Smart Search Enhancements

### 2.1 Current Gaps

- Search only in Lessons tab
- No debouncing (fires on every keystroke)
- No relevance ranking (exact match vs contains)
- No search history or suggestions
- Fidel character search: `contains` only — no fuzzy match for similar characters

### 2.2 Improvements

| Enhancement | Description | Effort |
|-------------|-------------|--------|
| **Debounce** | Wait 300ms after typing before search | Low |
| **Relevance ranking** | Exact match > starts with > contains; boost by frequency | Low |
| **Global search** | Search bar in tab bar or Home (search from anywhere) | Medium |
| **Search suggestions** | "Recent: ሰላም" or "Popular: greetings" | Medium |
| **Fuzzy Fidel** | Handle common typos (e.g. "selam" → ሰላም) | Medium |
| **Search filters** | Filter by type: Lessons | Words | Characters | Low |

### 2.3 Future: Semantic Search

- "words for family" → vocabulary lesson 2
- "how do you say hello" → ሰላም
- Requires: embeddings or keyword mapping (Phase 2)

---

## 3. Analytics Enhancements

### 3.1 Event Collection (Extend)

| Event | Payload Additions | Use |
|-------|-------------------|-----|
| `quiz_answer` | `response_time_ms` | Identify slow/uncertain answers |
| `quiz_answer` | `session_id` | Group questions into sessions |
| `flashcard_review` | `time_on_card_ms` | Engagement, difficulty |
| `lesson_view` | `duration_seconds` (on disappear) | Time spent |
| `audio_play` | Add to lesson/quiz flows | Track pronunciation usage |

### 3.2 New Insights

| Insight | Source | UI |
|---------|--------|-----|
| **Study time distribution** | `lesson_view` timestamps | "You learn best in the morning" |
| **Session length** | Consecutive events | "Avg session: 8 min" |
| **Retention curve** | Quiz correct % by days since lesson | Spaced repetition tuning |
| **Vowel confusion** | Quiz wrong answers, group by vowel_order | "You mix up ሀ and ሃ" |

### 3.3 Progress Tab Analytics

- **Accuracy over time** — Line chart (last 7 or 30 days)
- **Words by category** — "Greetings: 10/10, Family: 7/12"
- **Streak calendar** — GitHub-style contribution grid

---

## 4. Intelligence Enhancements

### 4.1 Smarter Recommendations

| Enhancement | Logic |
|-------------|-------|
| **Review weak → focused session** | "Review weak letters" opens quiz with only weak chars (from InsightsService) |
| **Continue → scroll to lesson** | Navigate to Lessons and scroll/highlight next lesson |
| **Spaced repetition** | If flashcards have `next_review_at` in past, add "Review flashcards" |
| **Time-aware** | "Good evening — 5 min review?" when short on time |
| **Streak rescue** | "2 min to midnight — quick lesson?" when streak at risk |

### 4.2 Adaptive Content

| Enhancement | Description |
|-------------|-------------|
| **Quiz difficulty** | More weak items when accuracy is low; more new items when mastery is high |
| **Flashcard deck** | "Review weak" deck built from InsightsService |
| **Lesson order** | Suggest next lesson based on weak consonant groups |

### 4.3 Personalization

| Enhancement | Description |
|-------------|-------------|
| **Daily goal** | Let user set goal (3, 5, 10 min or 1, 3, 5 lessons) |
| **Reminder time** | "Notify me at 8am" for streak |
| **Learning style** | Preference: more audio / more visual / more quiz |

---

## 5. Implementation Priority

### Phase A: Quick Wins (1–2 days)

1. Debounce search (300ms)
2. Haptic feedback on quiz correct/wrong
3. Pull-to-refresh on Home
4. Search relevance ranking (exact > prefix > contains)

### Phase B: UX Polish (3–5 days)

1. Skeleton loaders for Lessons, Practice
2. Recommendation deep link: "Review weak" → weak-only quiz
3. Mastery chart in Progress tab (from InsightsService)
4. Streak at risk visual (pulsing, color change)

### Phase C: Analytics & Intelligence (1 week)

1. Add `response_time_ms`, `session_id` to quiz events
2. Add `time_on_card_ms` to flashcard events
3. Study time distribution insight
4. "Review weak" quiz mode (filter by weak chars/words)

### Phase D: Advanced (2+ weeks)

1. Global search (tab bar or Home)
2. Search history & suggestions
3. Spaced repetition for flashcards (use `next_review_at`)
4. Accuracy-over-time chart in Progress

---

## 6. Summary Matrix

| Area | Quick Win | Medium | Advanced |
|------|-----------|--------|----------|
| **UI/UX** | Haptics, pull-refresh, skeletons | Deep links, mastery chart | Confetti, onboarding |
| **Search** | Debounce, relevance | Filters, global search | Fuzzy, suggestions |
| **Analytics** | response_time, time_on_card | Study time, session length | Retention curve |
| **Intelligence** | Deep link to weak quiz | Weak-only quiz mode | Adaptive difficulty, SRS |

---

## 7. Recommended Next Steps

1. **Debounce search** — Reduces jank, improves perceived performance
2. **"Review weak" deep link** — Recommendation cards become actionable
3. **Haptic feedback** — Low effort, high perceived polish
4. **Mastery chart in Progress** — Surface InsightsService data visually
