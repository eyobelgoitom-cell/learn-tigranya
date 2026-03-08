# Fidel Learn — Implementation Plan

**Created:** March 2025  
**Based on:** Codebase analysis + DEVELOPMENT_PLAN.md

---

## 1. Codebase Analysis Summary

### Strengths
- Clean MVVM architecture, protocol-based services
- Offline-first LocalLessonService with 154 Fidel chars, 22 lessons
- Flashcards and quizzes fully functional
- Supabase schema ready (user_progress, user_stats)
- UI components (CardView) reusable

### Gaps Identified

| # | Area | Issue | Priority |
|---|------|-------|----------|
| 1 | **Lesson progress** | `LessonsViewModel.progress(for:)` always returns `nil` | P0 |
| 2 | **Finish lesson** | AlphabetLessonView "Finish" doesn't save progress | P0 |
| 3 | **ProgressService** | No `getLessonProgress(lessonId)`; requires auth (offline users get 0) | P0 |
| 4 | **Local progress** | No offline progress storage — Supabase requires auth | P0 |
| 5 | **Vocabulary** | `words.json` is empty `[]` — need 100 words | P0 |
| 6 | **Home continue** | `HomeViewModel.continueLesson()` does nothing — no navigation | P1 |
| 7 | **getNextLesson** | Returns first lesson always, not first incomplete | P1 |
| 8 | **Pronunciation** | PronunciationPracticeView is placeholder | P2 |
| 9 | **Schema mismatch** | Supabase lessons use UUID; local use "lesson-1" | P2 |

---

## 2. Implementation Plan

### Phase A: Offline Progress (P0)

1. **LocalProgressService** — Store lesson completion in UserDefaults
   - Keys: `lesson_progress_{lessonId}` → completed, score, completedAt
   - Methods: `getLessonProgress`, `saveProgress`, `getLessonsCompleted`, `getStreak`, `getDailyProgress`
   - Works without auth; sync to Supabase when online (future)

2. **ProgressServiceProtocol** — Add `getLessonProgress(lessonId: String) async -> LessonProgress?`

3. **LessonsViewModel** — Inject LocalProgressService; implement `progress(for:)` with real data

4. **AlphabetLessonView** — On "Finish", call `progressService.saveProgress(lessonId, completed: true)`

5. **HomeViewModel** — Use LocalProgressService for streak/daily; implement `continueLesson` navigation

### Phase B: Vocabulary (P0)

6. **words.json** — 100 Tigrinya words grouped by category
   - Structure: id, fidel, transliteration, translation, lesson_id, order
   - Categories: greetings, family, numbers, body, food, common verbs, etc.
   - Use `vocabulary` section/lesson_id for grouping

### Phase C: Navigation & UX (P1)

7. **RootView / Tab** — Home "Continue" should switch to Lessons tab and optionally scroll to next lesson
   - Use `@Binding` or environment to switch tabs from Home

8. **LocalLessonService.getNextLesson** — Return first lesson not yet completed (from LocalProgressService)

### Phase D: Polish (P2)

9. **PronunciationPracticeView** — Basic implementation: show Fidel chars, play button each
10. **Ethiopic font** — Add Noto Sans Ethiopic if not present

---

## 3. File Changes Overview

| File | Action |
|-----|--------|
| `Core/API/LocalProgressService.swift` | **Create** — UserDefaults-based progress |
| `Core/API/ProgressService.swift` | Add `getLessonProgress`; LocalProgressService implements for offline |
| `Models/UserProgress.swift` | No change (LessonProgress exists) |
| `Features/Lessons/LessonsViewModel.swift` | Use LocalProgressService, implement `progress(for:)` |
| `Features/Lessons/AlphabetLessonView.swift` | Save progress on Finish |
| `Features/Home/HomeViewModel.swift` | Use LocalProgressService; add navigation callback |
| `Features/Home/HomeView.swift` | Wire continueLesson to tab switch |
| `Core/Navigation/RootView.swift` | Expose selectedTab binding for Home |
| `Resources/Data/words.json` | **Create** — 100 words |
| `Resources/Data/lessons.json` | Add vocabulary section + lessons (optional) |

---

## 4. Execution Order

1. ✅ LocalProgressService
2. ✅ ProgressServiceProtocol extension + LocalProgressService conformance
3. ✅ LessonsViewModel + AlphabetLessonView
4. ✅ HomeViewModel + RootView (tab switch)
5. ✅ HomeViewModel.getNextIncompleteLesson()
6. ✅ words.json (100 words) + vocabulary lessons

---

## 5. Implemented (March 2025)

| Item | Status |
|------|--------|
| LocalProgressService (UserDefaults) | ✅ |
| getLessonProgress in protocol + both services | ✅ |
| LessonsViewModel progress loading | ✅ |
| AlphabetLessonView save on Finish | ✅ |
| LessonsView refreshProgress on appear | ✅ |
| Home Continue → switch to Lessons tab | ✅ |
| Home nextLesson = first incomplete | ✅ |
| 100 words in words.json | ✅ |
| 5 vocabulary lessons in lessons.json | ✅ |
