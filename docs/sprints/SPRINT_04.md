# Sprint 4 — Flashcards

**Duration:** 2 weeks  
**Branch:** `feature/LIN-04-flashcards`  
**Goal:** Spaced repetition flashcards for Fidel characters.

---

## Sprint Backlog

| ID | Task | Status |
|----|------|--------|
| LIN-04-1 | Create `FlashcardSession` engine | ✅ Done |
| LIN-04-2 | Create `FlashcardPracticeViewModel` | ✅ Done |
| LIN-04-3 | Build `FlashcardPracticeView` with card flip | ✅ Done |
| LIN-04-4 | Add "Know it" / "Review later" actions | ✅ Done |
| LIN-04-5 | Add play button on card back | ✅ Done |

---

## Definition of Done

- [x] Card flip animation (3D rotation)
- [x] Front: Fidel character, "Tap to reveal"
- [x] Back: character, transliteration, play button
- [x] "Know it" advances, "Review later" adds to queue
- [x] Session complete when deck + review queue empty
- [x] Loads all 154 Fidel characters from lessons

---

## Files Created

```
FidelLearn/Sources/Features/Practice/
├── FlashcardSession.swift
├── FlashcardPracticeView.swift
└── FlashcardPracticeViewModel.swift
```
