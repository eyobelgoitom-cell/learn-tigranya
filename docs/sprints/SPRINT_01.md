# Sprint 1 — Foundation & Fidel Data

**Duration:** 2 weeks  
**Branch:** `feature/LIN-01-foundation-and-fidel-data`  
**Goal:** Offline-first data layer, full Tigrinya Fidel dataset, bug fixes

---

## Sprint Backlog

| ID | Task | Status | Assignee |
|----|------|--------|----------|
| LIN-01-1 | Fix ProgressService `getWordsLearned` and `getAccuracy` | ✅ Done | — |
| LIN-01-2 | Create `fidel_characters.json` (154 chars, 22 rows) | ✅ Done | — |
| LIN-01-3 | Create `lessons.json` (22 alphabet lessons) | ✅ Done | — |
| LIN-01-4 | Implement `LocalLessonService` | ✅ Done | — |
| LIN-01-5 | Add `words.json` placeholder (empty array) | ✅ Done | — |
| LIN-01-6 | Wire app to use `LocalLessonService` as primary | ✅ Done | — |
| LIN-01-7 | Add JSON to bundle (Resources/Data) | ✅ Done | — |
| LIN-01-8 | Unit tests for `LocalLessonService` | ✅ Done | — |

---

## Definition of Done

- [x] All JSON files load from bundle
- [x] `LocalLessonService` returns 22 alphabet lessons (Tigrinya standard)
- [x] App shows full lesson list without Supabase
- [x] No regressions; existing UI still works
- [x] Unit tests for LocalLessonService

---

## Notes

- Tigrinya uses 22 consonant groups (Adey standard); Amharic has 33
- Using 22 × 7 = 154 characters for Tigrinya MVP
- Can expand to 33 for Amharic in Phase 2
