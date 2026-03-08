# Fidel Learn

A modern native iOS app for learning Tigrinya and Amharic through the Ge'ez (Fidel) script, vocabulary, pronunciation, and phrases.

**Development progress:** See [docs/DEVELOPMENT_LOG.md](docs/DEVELOPMENT_LOG.md) for full changelog (Sprints 1–5 complete).

## Tech Stack

- **Platform:** Native iOS (Swift 5.9+, SwiftUI)
- **Architecture:** MVVM
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Project Management:** Tuist
- **CI/CD:** GitHub Actions, Fastlane

## Requirements

- Xcode 15+
- iOS 16+
- Tuist 4.x
- Swift 5.9+

## Setup

### 1. Install Tuist

```bash
curl -Ls https://install.tuist.io | bash
```

### 2. Generate Xcode Project

```bash
tuist generate
```

### 3. Install Dependencies

Open `FidelLearn.xcodeproj` in Xcode. Swift Package Manager will resolve dependencies automatically.

### 4. Configure Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Run migrations:
   ```bash
   supabase db push
   ```
3. Add environment variables (create `FidelLearn/Config.xcconfig` or use Scheme environment):
   - `SUPABASE_URL` - Your Supabase project URL
   - `SUPABASE_ANON_KEY` - Your Supabase anon key

### 5. Run the App

```bash
xcodebuild -scheme FidelLearn -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Or open in Xcode and run (⌘R).

## Project Structure

```
FidelLearn/
├── Sources/
│   ├── App/                 # App entry, AppState
│   ├── Core/               # API, Navigation
│   ├── Features/           # Home, Lessons, Practice, Progress, Settings
│   ├── Models/             # User, Lesson, Word, Flashcard, UserProgress
│   └── UI/                 # Reusable components
├── Resources/
│   └── Assets.xcassets
supabase/
├── migrations/             # Database schema
└── config.toml
```

## Development

### Linting

```bash
swiftlint lint
swiftformat .
```

### Testing

```bash
xcodebuild test -scheme FidelLearn -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Fastlane

```bash
fastlane lint
fastlane test
fastlane beta   # TestFlight
```

## Branching

- `main` - Production
- `staging` - TestFlight / QA
- `develop` - Active development
- `feature/*` - Feature branches
- `fix/*` - Bug fixes
- `hotfix/*` - Production hotfixes

## License

Proprietary
