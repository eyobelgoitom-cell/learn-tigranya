# Fidel Learn — Development Plan

**Last updated:** March 2025  
**Target:** MVP (Tigrinya alphabet, 100 words, audio, flashcards, quizzes, progress)

---

## Current State

| Area | Status | Notes |
|------|--------|-------|
| App shell | ✅ Done | Tab nav: Home, Lessons, Practice, Progress, Settings |
| Models | ✅ Done | Lesson, Word, FidelCharacter, UserProgress, Flashcard |
| Supabase schema | ✅ Done | Migrations ready |
| LessonService | ⚠️ Partial | Supabase + fallback; fallback has 1 lesson only |
| ProgressService | ⚠️ Bugs | `userId` undefined in `getWordsLearned`, `getAccuracy` |
| Lesson detail screen | ❌ Missing | Tapping lesson does nothing |
| Fidel dataset | ❌ Missing | Need full 231 Tigrinya characters |
| Vocabulary | ❌ Missing | Need 100 words |
| Audio | ❌ Missing | No playback |
| Flashcards | ❌ Placeholder | UI shell only |
| Quizzes | ❌ Placeholder | UI shell only |
| Offline | ❌ Missing | App depends on Supabase |

---

## Phase 1: Foundation (Sprint 1)

**Goal:** Fix bugs, add offline-first data, full Fidel dataset.

### 1.1 Fix ProgressService
- [ ] Fix `getWordsLearned()` — use `guard let userId = await currentUserId()`
- [ ] Fix `getAccuracy()` — same fix

### 1.2 Local Data Layer
- [ ] Create `LocalLessonService` implementing `LessonServiceProtocol`
- [ ] Bundle JSON: `fidel_characters.json`, `lessons.json`, `words.json`
- [ ] Use local service when offline or as primary for MVP

### 1.3 Tigrinya Fidel Dataset
- [ ] Create `fidel_characters.json` with all 231 characters
- [ ] Structure: 33 consonant groups × 7 vowels (ሀ ሁ ሂ ሃ ሄ ህ ሆ)
- [ ] Include: character, transliteration, vowel_order, consonant_group

### 1.4 Lesson Structure
- [ ] Create `lessons.json` — 33 alphabet lessons (one per consonant row)
- [ ] Lesson 1: ሀ ሁ ሂ ሃ ሄ ህ ሆ (ha, hu, hi, ha, he, hə, ho)

**Branch:** `feature/LIN-01-foundation-and-fidel-data`

---

## Phase 2: Alphabet Lesson Screen (Sprint 2)

**Goal:** User can open a lesson and see Fidel characters.

### 2.1 Lesson Detail View
- [ ] `AlphabetLessonView` — full-screen lesson
- [ ] Display 7 characters per row (one vowel row)
- [ ] Large Fidel typography (Noto Sans Ethiopic / Abyssinica SIL)
- [ ] Transliteration below each character

### 2.2 Navigation
- [ ] Wire `LessonsViewModel.selectedLesson` → `AlphabetLessonView`
- [ ] Use `NavigationLink` or sheet based on lesson type

### 2.3 Progress Integration
- [ ] Load `progress(for: lessonId)` from ProgressService
- [ ] Mark lesson complete on "Finish" action

**Branch:** `feature/LIN-02-alphabet-lesson-screen`

---

## Phase 3: Audio System (Sprint 3)

**Goal:** Play pronunciation for letters and words.

### 3.1 Audio Service
- [ ] `AudioService` protocol + `AVAudioPlayer` implementation
- [ ] Support: play, stop, slow/normal speed

### 3.2 Audio Sources
- [ ] Option A: Bundle MP3 files per character/word
- [ ] Option B: TTS fallback (AVSpeechSynthesizer) for MVP
- [ ] Option C: Supabase Storage URLs (requires network)

### 3.3 UI Integration
- [ ] Play button on each Fidel character in lesson
- [ ] Play button on flashcards and quiz items

**Branch:** `feature/LIN-03-audio-pronunciation`

---

## Phase 4: Flashcards (Sprint 4)

**Goal:** Spaced repetition flashcards for letters and words.

### 4.1 Flashcard Engine
- [ ] `FlashcardSession` — manages deck, flip, next
- [ ] Support both FidelCharacter and Word cards
- [ ] "Know it" / "Review later" actions

### 4.2 Flashcard UI
- [ ] Card flip animation
- [ ] Front: Fidel character/word
- [ ] Back: transliteration, translation, example

### 4.3 Spaced Repetition (Optional for MVP)
- [ ] Simple: "repeat later" = back of queue
- [ ] Full SM-2: defer to Phase 5+

**Branch:** `feature/LIN-04-flashcards`

---

## Phase 5: Quizzes (Sprint 5)

**Goal:** Multiple choice, match, and listening quizzes.

### 5.1 Quiz Types
- [ ] **Multiple choice:** "What sound is ሀ?" → A) ha B) sa C) ka
- [ ] **Match:** Sound → letter
- [ ] **Listening:** Play audio → choose letter

### 5.2 Quiz Engine
- [ ] `QuizSession` — questions, scoring, completion
- [ ] Pull from lesson's Fidel characters/words

### 5.3 Quiz UI
- [ ] Question display
- [ ] Answer buttons with feedback (correct/incorrect)
- [ ] Score and "Try again" / "Next"

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

1. Checkout `develop`
2. Create `feature/LIN-01-foundation-and-fidel-data`
3. Fix ProgressService bugs
4. Add local data layer + Fidel JSON
