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
│   │   │   │   ├── LessonService.swift
│   │   │   │   └── ProgressService.swift
│   │   │   └── Navigation/
│   │   │       └── RootView.swift
│   │   ├── Features/          # Feature modules
│   │   │   ├── Home/
│   │   │   ├── Lessons/
│   │   │   ├── Practice/
│   │   │   ├── Progress/
│   │   │   └── Settings/
│   │   ├── Models/            # Data models
│   │   │   ├── User.swift
│   │   │   ├── Lesson.swift
│   │   │   ├── Word.swift
│   │   │   ├── Flashcard.swift
│   │   │   ├── UserProgress.swift
│   │   │   └── FidelCharacter.swift
│   │   └── UI/                # Reusable UI components
│   │       └── Components/
│   │           └── CardView.swift
│   └── Resources/
│       └── Assets.xcassets
├── FidelLearnTests/
│   └── Sources/
├── FidelLearnUITests/
│   └── Sources/
├── supabase/
│   ├── migrations/            # Database schema
│   └── config.toml
├── fastlane/
├── .github/workflows/
└── docs/
```

## Architecture (MVVM)

- **View**: SwiftUI views (e.g., `HomeView`)
- **ViewModel**: `@MainActor` ObservableObject (e.g., `HomeViewModel`)
- **Model**: Codable structs matching Supabase tables
- **Service**: Protocol-based API layer (e.g., `LessonServiceProtocol`)

## Data Flow

1. **Supabase** → API layer (LessonService, ProgressService, AuthService)
2. **Services** → ViewModels (injected via init)
3. **ViewModels** → Views (via `@StateObject`)

## Key Conventions

- Use protocols for services (enables testing, offline mocks)
- Keep ViewModels on `@MainActor`
- Models use `CodingKeys` for snake_case ↔ camelCase
- Environment variables for Supabase URL and anon key
