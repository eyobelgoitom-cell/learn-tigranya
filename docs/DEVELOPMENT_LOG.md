# Fidel Learn — Development Log

**Project:** Tigrinya / Amharic Learning App  
**Platform:** Native iOS (Swift, SwiftUI)  
**Last updated:** March 2025

---

## Overview

This document records all development work completed on Fidel Learn, from initial setup through Sprint 3.

---

## Pre-Development Setup

### Repository & Branches

- **GitHub:** `eyobelgoitom-cell/learn-tigranya`
- **Branches created:** `main`, `staging`, `develop`
- **Remote:** `https://github.com/eyobelgoitom-cell/learn-tigranya.git`

### Project Configuration

- **Tuist 4** — Project generation (fixed `Project.swift` options for Tuist 4 API)
- **Xcode** — `xcode-select -s /Applications/Xcode.app` for build tools

### Rules & Guidelines Added

- **Core Principles** (`.cursor/rules/development-workflow.mdc`):
  - Simplicity first, Modular architecture, Testable code
  - Performance awareness, Security by default
  - Stunning premium UI
- **UI/UX Guide** (`docs/UI_UX_GUIDE.md`) — Design pillars, visual system, component guidelines
- **PRD Design Requirements** — Expanded with premium UI mandate

---

## Sprint 1 — Foundation & Fidel Data

**Branch:** `feature/LIN-01-foundation-and-fidel-data`  
**Status:** ✅ Complete

### Deliverables

| Item | Description |
|------|-------------|
| **ProgressService fix** | Fixed `getWordsLearned()` and `getAccuracy()` — corrected `userId` guard |
| **fidel_characters.json** | 154 Tigrinya Fidel characters (22 consonant rows × 7 vowels) |
| **lessons.json** | 22 alphabet lessons (ሀ→ፖ) |
| **words.json** | Empty placeholder for vocabulary |
| **LocalLessonService** | Offline-first service loading from bundled JSON |
| **App wiring** | HomeViewModel & LessonsViewModel use LocalLessonService by default |
| **Unit tests** | Tests for LocalLessonService (lesson sections, Fidel characters) |

### Files Created

```
FidelLearn/Resources/Data/
├── fidel_characters.json
├── lessons.json
└── words.json

FidelLearn/Sources/Core/API/
└── LocalLessonService.swift

docs/sprints/
└── SPRINT_01.md
```

### Tigrinya Fidel Dataset

- **22 consonant groups:** ሀ, ለ, መ, ረ, ሰ, ቀ, በ, ተ, ነ, አ, ከ, ወ, ዘ, የ, ደ, ገ, ጠ, ጰ, ጸ, ፀ, ፈ, ፐ
- **7 vowels per row:** ä, u, i, a, e, ə, o
- **Source:** Adey Tigrinya Alphabet Guide

---

## Sprint 2 — Alphabet Lesson Screen

**Branch:** `feature/LIN-02-alphabet-lesson-screen`  
**Status:** ✅ Complete

### Deliverables

| Item | Description |
|------|-------------|
| **AlphabetLessonView** | Full-screen lesson with header, character grid, Finish button |
| **AlphabetLessonViewModel** | Loads Fidel characters for selected lesson |
| **FidelCharacterCell** | 52pt Fidel, transliteration, card layout |
| **Navigation** | NavigationLink from LessonsView → AlphabetLessonView |

### Files Created/Updated

```
FidelLearn/Sources/Features/Lessons/
├── AlphabetLessonView.swift      (new)
├── AlphabetLessonViewModel.swift (new)
└── LessonsView.swift             (updated)

docs/sprints/
└── SPRINT_02.md
```

### UI Details

- Horizontal scroll for 7 characters per lesson
- 52pt Fidel typography
- Transliteration below each character
- Card-style cells (16pt radius, subtle shadow)
- Premium styling per UI_UX_GUIDE

---

## Sprint 3 — Audio System

**Branch:** `feature/LIN-03-audio-pronunciation`  
**Status:** ✅ Complete

### Deliverables

| Item | Description |
|------|-------------|
| **AudioService** | Protocol + TTS implementation (AVSpeechSynthesizer) |
| **Play button** | On each Fidel character in AlphabetLessonView |
| **Pronunciation** | Speaks transliteration (e.g., "ha", "hu", "la") |

### Files Created/Updated

```
FidelLearn/Sources/Core/Audio/
└── AudioService.swift          (new)

FidelLearn/Sources/Features/Lessons/
└── AlphabetLessonView.swift     (updated — play button)

docs/sprints/
└── SPRINT_03.md
```

### Technical Notes

- Uses `AVSpeechSynthesizer` — speaks Latin transliteration
- Rate 0.4 for clear pronunciation
- No network required
- Native Tigrinya/Amharic TTS would require bundled audio (future)

---

## Current Architecture

### Source Structure

```
FidelLearn/Sources/
├── App/
│   ├── FidelLearnApp.swift
│   └── AppState.swift
├── Core/
│   ├── API/
│   │   ├── AuthService.swift
│   │   ├── DefaultAuthService.swift
│   │   ├── LessonService.swift
│   │   ├── LocalLessonService.swift    ← Sprint 1
│   │   ├── ProgressService.swift
│   │   └── SupabaseClient.swift
│   ├── Audio/
│   │   └── AudioService.swift          ← Sprint 3
│   └── Navigation/
│       └── RootView.swift
├── Features/
│   ├── Home/
│   ├── Lessons/
│   │   ├── AlphabetLessonView.swift    ← Sprint 2
│   │   ├── AlphabetLessonViewModel.swift
│   │   ├── LessonsView.swift
│   │   └── LessonsViewModel.swift
│   ├── Practice/
│   ├── Progress/
│   └── Settings/
├── Models/
└── UI/Components/
```

### Data Flow

1. **LocalLessonService** (primary) → loads from bundled JSON
2. **LessonService** (Supabase) → fallback when online
3. **AudioService** → TTS for pronunciation
4. **ProgressService** → user progress (Supabase, requires auth)

### Key Conventions

- MVVM architecture
- Protocol-based services (testable, mockable)
- `@MainActor` for ViewModels
- Offline-first for lessons

---

## Sprint 4 — Flashcards

**Branch:** `feature/LIN-04-flashcards`  
**Status:** ✅ Complete

### Deliverables

| Item | Description |
|------|-------------|
| **FlashcardSession** | Deck management, flip, Know it / Review later |
| **FlashcardPracticeView** | Card flip animation, front/back, action buttons |
| **FlashcardPracticeViewModel** | Loads all Fidel chars from lessons |
| **Play button** | On card back for pronunciation |

### Files Created

```
FidelLearn/Sources/Features/Practice/
├── FlashcardSession.swift
├── FlashcardPracticeView.swift
└── FlashcardPracticeViewModel.swift
```

---

## Sprint 5 — Quizzes

**Branch:** `feature/LIN-05-quizzes`  
**Status:** ✅ Complete

### Deliverables

| Item | Description |
|------|-------------|
| **QuizSession** | Questions, scoring, correct/incorrect feedback |
| **QuizPracticeView** | MC question, 4 options, feedback, completion |
| **QuizPracticeViewModel** | Loads Fidel chars, builds 10-question quiz |
| **Unit test** | QuizSession scoring (per workflow rules) |

### Files Created

```
FidelLearn/Sources/Features/Practice/
├── QuizSession.swift
├── QuizPracticeView.swift
└── QuizPracticeViewModel.swift
```

---

## Sprint 6 — Vocabulary & Polish (continued)

**Branch:** `develop`  
**Status:** ✅ In progress

### Deliverables (March 2025)

| Item | Description |
|------|-------------|
| **Auth resolution** | `emitLocalSessionAsInitialSession: true`, session.isExpired loading overlay |
| **Progress sync** | UserProgressView, LessonsView, QuizPracticeView use SyncProgressService |
| **Quiz stats** | `recordQuizAttempt` persists accuracy; Progress tab reflects quiz performance |
| **Next lesson** | Home includes vocabulary lessons in "Continue Learning" |
| **Lessons UX** | Loading state, empty state, bundle path fallback for JSON resources |
| **Vocabulary flashcards** | `WordFlashcardSession`, `WordFlashcardView`; mode picker Alphabet/Vocabulary |
| **Vocabulary quiz** | `WordQuizSession`, `WordQuizQuestion`; word → translation MC; mode picker |

### Files Created

- `WordFlashcardSession.swift` — vocabulary deck, flip, Know it / Review later
- `WordQuizSession.swift` — vocabulary MC quiz (word → translation)

### Files Modified

- `SupabaseClient.swift` — Auth options
- `AuthService.swift`, `DefaultAuthService.swift` — isAuthResolvingPublisher
- `SyncProgressService.swift` — recordQuizAttempt, full protocol conformance
- `LocalProgressService.swift` — recordQuizAttempt (public)
- `RootView.swift` — inject progressService to all tabs
- `ProgressView.swift`, `LessonsView.swift`, `QuizPracticeView.swift` — SyncProgressService
- `QuizPracticeViewModel.swift` — submitAnswer → recordQuizAttempt

---

## References

- [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) — Full roadmap
- [PROJECT_STRUCTURE.md](./PROJECT_STRUCTURE.md) — Architecture
- [UI_UX_GUIDE.md](./UI_UX_GUIDE.md) — Design standards
- [PRD.md](../PRD.md) — Product requirements
