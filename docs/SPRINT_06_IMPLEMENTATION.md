# Sprint 6 — Implementation Summary

**Date:** March 2025  
**Focus:** Vocabulary, Progress Sync, Auth, Audio, Fonts

---

## ✅ Completed

### 1. Vocabulary (100 words)

- **`FidelLearn/Resources/Data/words.json`** — 100 Tigrinya words across 10 vocabulary lessons
- **`FidelLearn/Resources/Data/lessons.json`** — Added 10 vocabulary lessons (lesson-voc-1 through lesson-voc-10)

**Categories:**
| Lesson | Category | Sample words |
|--------|----------|--------------|
| lesson-voc-1 | Greetings & basics | ሰላም (hello), እወ (yes), ኣነ (I) |
| lesson-voc-2 | Family | ኣቦ (father), ኣደ (mother), ጓል (girl) |
| lesson-voc-3 | Body parts | ዓይኒ (eye), እዝኒ (ear), ርእሲ (head) |
| lesson-voc-4 | Food & drink | ምግቢ (food), ጸባ (milk), ማይ (water) |
| lesson-voc-5 | Home | ገዛ (home), መፅሓፍ (book), ኣልጋ (bed) |
| lesson-voc-6 | Common verbs | ግበር (do), ኪድ (go), ንዓ (come) |
| lesson-voc-7 | Descriptors | ፅቡቅ (good), ሕማቅ (bad), ዓብይ (big) |
| lesson-voc-8 | Nature | ፀሓይ (sun), ባሕሪ (sea), መሬት (land) |
| lesson-voc-9 | Animals | ከልቢ (dog), ድሙ (cat), በሬ (ox) |
| lesson-voc-10 | Places & time | መንገዲ (road), ከተማ (city), ሰዓት (time) |

### 2. Progress Sync to Supabase

- **`SyncProgressService.swift`** — Composite service: local-first + Supabase sync when authenticated
- **`FidelLearnApp.swift`** — Injects `SyncProgressService(appState:)` into environment
- **`AlphabetLessonView`** — Uses `@Environment(\.progressService)` for lesson completion

**Manual edits required** (see `PROGRESS_SYNC_MANUAL_EDITS.md`):
- `RootView.swift` — Add `@Environment(\.progressService)` and pass to `HomeView(progressService:)`
- `HomeView.swift` — Add `init(progressService:)` and pass to `HomeViewModel`

### 3. Auth Integration

- Auth already integrated in Settings (Sign In / Sign Out)
- `SyncProgressService` uses `AppState.isAuthenticated` to decide when to sync to Supabase
- When authenticated: progress saves to both UserDefaults and Supabase

### 4. Ethiopic Fonts

- **`FidelTheme.fidelFont`** — Uses Noto Sans Ethiopic when available, falls back to system font
- **`FidelLearn/Resources/Fonts/README.md`** — Instructions to download and add the font

**Manual steps:**
1. Download [Noto Sans Ethiopic](https://fonts.google.com/noto/specimen/Noto+Sans+Ethiopic)
2. Add `NotoSansEthiopic-Regular.ttf` to `FidelLearn/Resources/Fonts/`
3. Add Fonts folder to Xcode target "Copy Bundle Resources"
4. Add `UIAppFonts: ["Fonts/NotoSansEthiopic-Regular.ttf"]` to Info.plist (or Tuist `Project.swift`)

### 5. Audio — Native Speaker Placeholder

**Manual edits for `AudioService.swift`:**

Add URL playback support so that when `audio_url` is set on FidelCharacter or Word, the app plays from URL instead of TTS:

```swift
// Add to AudioService
func play(url: URL?, completion: (() -> Void)? = nil) async {
    guard let url else { return }
    // Use AVPlayer to play from URL
    // Fall back to TTS when url is nil (current behavior)
}
```

Update `FidelCharacterCell` and vocabulary word cells:
```swift
if let audioUrl = character.audioUrl, let url = URL(string: audioUrl) {
    await AudioService.shared.play(url: url)
} else {
    await AudioService.shared.play(text: character.transliteration)
}
```

---

## LessonsView Navigation

Ensure `LessonsView` routes to the correct detail view based on `lesson.type`:

```swift
// For alphabet lessons → AlphabetLessonView
// For vocabulary lessons → VocabularyLessonView
NavigationLink(value: lesson) {
    // ...
}
.navigationDestination(for: Lesson.self) { lesson in
    if lesson.type == .vocabulary {
        VocabularyLessonView(lesson: lesson)
    } else {
        AlphabetLessonView(lesson: lesson)
    }
}
```

Or use separate `NavigationLink` destinations per lesson type.

---

## Next Steps

1. **Apply manual edits** — RootView, HomeView, AudioService (see above and `PROGRESS_SYNC_MANUAL_EDITS.md`)
2. **Wire VocabularyLessonView** — Add navigation from LessonsView for vocabulary lessons (see above)
3. **Add font to project** — Follow Fonts/README.md
4. **TestFlight** — Run `fastlane beta` when ready

---

## Files Changed

| File | Status |
|------|--------|
| `words.json` | ✅ 100 words |
| `lessons.json` | ✅ 10 vocab lessons |
| `SyncProgressService.swift` | ✅ Created |
| `FidelLearnApp.swift` | ✅ Updated |
| `AlphabetLessonView.swift` | ✅ Uses env progressService |
| `FidelTheme.swift` | ✅ fidelFont added |
| `Fonts/README.md` | ✅ Created |
| `RootView.swift` | ⏳ Manual edit |
| `HomeView.swift` | ⏳ Manual edit |
| `AudioService.swift` | ⏳ Manual edit |
| `VocabularyLessonView.swift` | ⏳ Optional: play(url:) for words |
