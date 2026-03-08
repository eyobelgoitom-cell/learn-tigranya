# Manual Edits Required for Progress Sync

Some files could not be edited automatically due to filesystem timeouts. Apply these changes manually:

## 1. RootView.swift

**File:** `FidelLearn/Sources/Core/Navigation/RootView.swift`

Add at the top of the struct (after other @EnvironmentObject or @Environment):
```swift
@Environment(\.progressService) private var progressService
```

Change `HomeView()` to `HomeView(progressService: progressService)` wherever HomeView appears in the TabView.

## 2. HomeView.swift

**File:** `FidelLearn/Sources/Features/Home/HomeView.swift`

Replace:
```swift
@StateObject private var viewModel = HomeViewModel()
```

With:
```swift
let progressService: SyncProgressService
@StateObject private var viewModel: HomeViewModel

init(progressService: SyncProgressService) {
    self.progressService = progressService
    _viewModel = StateObject(wrappedValue: HomeViewModel(progressService: progressService))
}
```

## 3. SettingsView

SettingsView already has Sign In when not authenticated and Sign Out when authenticated. No changes needed.
