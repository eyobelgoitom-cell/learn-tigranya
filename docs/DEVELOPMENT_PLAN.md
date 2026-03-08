# Fidel Learn — Development Plan

**Last updated:** March 2025  
**Target:** MVP (Tigrinya alphabet, 100 words, audio, flashcards, quizzes, progress)

**UI/UX:** See [UI_UX_GUIDE.md](./UI_UX_GUIDE.md) — every screen must be stunning, premium, and user-friendly.

---

## Current State

| Area | Status | Notes |
|------|--------|-------|
| App shell | ✅ Done | Tab nav: Home, Lessons, Practice, Progress, Settings |
| Models | ✅ Done | Lesson, Word, FidelCharacter, UserProgress, Flashcard |
| Supabase schema | ✅ Done | Migrations ready |
| LocalLessonService | ✅ Done | Offline-first, 22 lessons, 154 Fidel chars |
| ProgressService | ✅ Done | Bug fixes applied |
| Lesson detail screen | ✅ Done | AlphabetLessonView with Fidel display |
| Fidel dataset | ✅ Done | 154 chars (22 rows × 7 vowels) |
| Vocabulary | ❌ Missing | Need 100 words |
| Audio | ✅ Done | TTS on each Fidel character |
| Flashcards | ✅ Done | Card flip, Know it / Review later |
| Quizzes | ✅ Done | Multiple choice |
| Offline | ✅ Done | LocalLessonService primary |

**See [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) for full changelog.**

---

## Phase 1: Foundation (Sprint 1)

**Goal:** Fix bugs, add offline-first data, full Fidel dataset.

### 1.1 Fix ProgressService
- [x] Fix `getWordsLearned()` — use `guard let userId = await currentUserId()`
- [x] Fix `getAccuracy()` — same fix

### 1.2 Local Data Layer
- [x] Create `LocalLessonService` implementing `LessonServiceProtocol`
- [x] Bundle JSON: `fidel_characters.json`, `lessons.json`, `words.json`
- [x] Use local service when offline or as primary for MVP

### 1.3 Tigrinya Fidel Dataset
- [x] Create `fidel_characters.json` with 154 characters (22 rows × 7 vowels)
- [x] Structure: 22 consonant groups × 7 vowels (ሀ ሁ ሂ ሃ ሄ ህ ሆ)
- [x] Include: character, transliteration, vowel_order, consonant_group

### 1.4 Lesson Structure
- [x] Create `lessons.json` — 22 alphabet lessons (one per consonant row)
- [x] Lesson 1: ሀ ሁ ሂ ሃ ሄ ህ ሆ (ha, hu, hi, ha, he, hə, ho)

**Branch:** `feature/LIN-01-foundation-and-fidel-data`

---

## Phase 2: Alphabet Lesson Screen (Sprint 2)

**Goal:** User can open a lesson and see Fidel characters.

### 2.1 Lesson Detail View
- [x] `AlphabetLessonView` — full-screen lesson
- [x] Display 7 characters per row (one vowel row)
- [x] Large Fidel typography (52pt)
- [x] Transliteration below each character

### 2.2 Navigation
- [x] Wire `NavigationLink` from LessonsView → AlphabetLessonView

### 2.3 Progress Integration
- [ ] Load `progress(for: lessonId)` from ProgressService
- [ ] Mark lesson complete on "Finish" action

**Branch:** `feature/LIN-02-alphabet-lesson-screen`

---

## Phase 3: Audio System (Sprint 3)

**Goal:** Play pronunciation for letters and words.

### 3.1 Audio Service
- [x] `AudioService` protocol + TTS (AVSpeechSynthesizer)
- [x] Support: play, stop

### 3.2 Audio Sources
- [x] TTS fallback (AVSpeechSynthesizer) for MVP
- [ ] Option A: Bundle MP3 files (future)
- [ ] Option C: Supabase Storage URLs (future)

### 3.3 UI Integration
- [x] Play button on each Fidel character in lesson
- [ ] Play button on flashcards and quiz items

**Branch:** `feature/LIN-03-audio-pronunciation`

---

## Phase 4: Flashcards (Sprint 4)

**Goal:** Spaced repetition flashcards for letters and words.

### 4.1 Flashcard Engine
- [x] `FlashcardSession` — manages deck, flip, next
- [x] Support FidelCharacter cards
- [x] "Know it" / "Review later" actions

### 4.2 Flashcard UI
- [x] Card flip animation (3D rotation)
- [x] Front: Fidel character
- [x] Back: transliteration, play button

### 4.3 Spaced Repetition (Optional for MVP)
- [x] Simple: "Review later" = back of queue
- [ ] Full SM-2: defer to Phase 5+

**Branch:** `feature/LIN-04-flashcards`

---

## Phase 5: Quizzes (Sprint 5)

**Goal:** Multiple choice, match, and listening quizzes.

### 5.1 Quiz Types
- [x] **Multiple choice:** "What sound is ሀ?" → 4 options
- [ ] **Match:** Sound → letter (deferred)
- [ ] **Listening:** Play audio → choose letter (deferred)

### 5.2 Quiz Engine
- [x] `QuizSession` — questions, scoring, completion
- [x] Pull from Fidel characters

### 5.3 Quiz UI
- [x] Question display
- [x] Answer buttons with feedback (correct/incorrect)
- [x] Score and "Try again" / "Next"

**Branch:** `feature/LIN-05-quizzes`

---

## Phase 6: Vocabulary & Polish (Sprint 6)

**Goal:** 100 words, offline support, TestFlight-ready.

### 6.1 Vocabulary
- [ ] Create `words.json` with 100 Tigrinya words
- [ ] Group by lessons (e.g., greetings, family, numbers)

### 6.2 Offline-First
- [ ] Default to `LocalLessonService`
- [ ] Sync progress to Supabase when online (optional)

### 6.3 Polish
- [ ] Add Ethiopic fonts to project
- [ ] Dark mode support
- [ ] App icon, launch screen

**Branch:** `feature/LIN-06-vocabulary-and-polish`

---

## Sprint Overview

| Sprint | Focus | Key Deliverables |
|--------|-------|------------------|
| 1 | Foundation | Bug fixes, Fidel data, local service |
| 2 | Lessons | Alphabet lesson screen, navigation |
| 3 | Audio | Playback for letters/words |
| 4 | Flashcards | Card flip, basic SRS |
| 5 | Quizzes | MC, match, listening |
| 6 | Vocabulary & Polish | 100 words, offline, fonts |

---

## Branching

- Work on `develop`
- Feature branches: `feature/LIN-XX-description`
- Merge to `develop` → PR → merge to `staging` for TestFlight

---

## Next Steps

1. Sprint 6: Vocabulary (100 words), polish, TestFlight
