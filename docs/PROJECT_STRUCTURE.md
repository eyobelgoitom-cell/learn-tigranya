# Fidel Learn - Project Structure

## Folder Layout

```
learn tigraynya/
├── Project.swift              # Tuist project definition
├── Tuist/
│   └── Config.swift           # Tuist configuration
├── FidelLearn/
│   ├── Sources/
│   │   ├── App/               # App entry point, AppState
│   │   │   ├── FidelLearnApp.swift
│   │   │   └── AppState.swift
│   │   ├── Core/              # Shared infrastructure
│   │   │   ├── API/           # Supabase client, services
│   │   │   │   ├── SupabaseClient.swift
│   │   │   │   ├── AuthService.swift
│   │   │   │   ├── DefaultAuthService.swift
│   │   │   │   ├── LessonService.swift
│   │   │   │   ├── LocalLessonService.swift   # Offline-first (Sprint 1)
│   │   │   │   └── ProgressService.swift
│   │   │   ├── Audio/         # Pronunciation (Sprint 3)
│   │   │   │   └── AudioService.swift
│   │   │   └── Navigation/
│   │   │       └── RootView.swift
│   │   ├── Features/          # Feature modules
│   │   │   ├── Home/
│   │   │   ├── Lessons/       # AlphabetLessonView (Sprint 2)
│   │   │   │   ├── AlphabetLessonView.swift
│   │   │   │   ├── AlphabetLessonViewModel.swift
│   │   │   │   ├── LessonsView.swift
│   │   │   │   └── LessonsViewModel.swift
│   │   │   ├── Practice/
│   │   │   ├── Progress/
│   │   │   └── Settings/
│   │   ├── Models/
│   │   └── UI/Components/
│   └── Resources/
│       ├── Assets.xcassets
│       └── Data/              # Bundled JSON (Sprint 1)
│           ├── fidel_characters.json
│           ├── lessons.json
│           └── words.json
├── FidelLearnTests/
├── FidelLearnUITests/
├── supabase/
├── fastlane/
├── .github/workflows/
└── docs/
    ├── DEVELOPMENT_LOG.md     # Full changelog
    ├── DEVELOPMENT_PLAN.md
    ├── PROJECT_STRUCTURE.md
    ├── UI_UX_GUIDE.md
    └── sprints/
        ├── SPRINT_01.md
        ├── SPRINT_02.md
        └── SPRINT_03.md
```

## Architecture (MVVM)

- **View**: SwiftUI views (e.g., `HomeView`)
- **ViewModel**: `@MainActor` ObservableObject (e.g., `HomeViewModel`)
- **Model**: Codable structs matching Supabase tables
- **Service**: Protocol-based API layer (e.g., `LessonServiceProtocol`)

## Data Flow

1. **LocalLessonService** (primary) → bundled JSON, offline-first
2. **LessonService** (Supabase) → fallback when online
3. **AudioService** → TTS for Fidel pronunciation
4. **Services** → ViewModels (injected via init)
5. **ViewModels** → Views (via `@StateObject`)

## Key Conventions

- Use protocols for services (enables testing, offline mocks)
- Keep ViewModels on `@MainActor`
- Models use `CodingKeys` for snake_case ↔ camelCase
- Environment variables for Supabase URL and anon key
