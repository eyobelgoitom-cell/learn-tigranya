# Sprint 3 — Audio System

**Duration:** 2 weeks  
**Branch:** `feature/LIN-03-audio-pronunciation`  
**Goal:** Play pronunciation for Fidel characters and words.

---

## Sprint Backlog

| ID | Task | Status |
|----|------|--------|
| LIN-03-1 | Create `AudioService` protocol | ✅ Done |
| LIN-03-2 | Implement TTS with AVSpeechSynthesizer | ✅ Done |
| LIN-03-3 | Add play button to FidelCharacterCell | ✅ Done |
| LIN-03-4 | Wire audio speed from Settings (optional) | ⏳ Deferred |

---

## Definition of Done

- [x] Play button on each Fidel character in lesson
- [x] TTS speaks transliteration (e.g., "ha", "hu")
- [x] No network required
- [ ] Audio speed from Settings (deferred to polish)

---

## Notes

- Uses AVSpeechSynthesizer — speaks Latin transliteration
- Native Tigrinya/Amharic TTS would require bundled audio files (future)
- Rate set to 0.4 for clear pronunciation
