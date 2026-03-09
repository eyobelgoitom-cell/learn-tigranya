import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel: LessonsViewModel
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(progressService: SyncProgressService) {
        _viewModel = StateObject(wrappedValue: LessonsViewModel(progressService: progressService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    List {
                        Section {
                            ForEach(0..<6, id: \.self) { _ in
                                LessonSkeletonRow()
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollDisabled(true)
                } else if viewModel.lessonSections.isEmpty {
                    emptyStateView
                } else {
                    List {
                        if !viewModel.searchText.isEmpty {
                            Section("Search Results") {
                                if viewModel.isSearching {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .listRowBackground(Color.clear)
                                } else if viewModel.searchResults.isEmpty {
                                    Text("No results for \"\(viewModel.searchText)\"")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .listRowBackground(Color.clear)
                                } else {
                                    ForEach(viewModel.searchResults) { result in
                                        if let lesson = result.lesson {
                                            NavigationLink(value: lesson) {
                                                SearchResultRow(result: result, progress: viewModel.progress(for: lesson.id))
                                            }
                                        } else {
                                            SearchResultRow(result: result, progress: nil)
                                        }
                                    }
                                }
                            }
                        }
                        if viewModel.searchText.isEmpty, let teaser = viewModel.progressTeaser {
                            Section {
                                lessonsHeroRow(teaser: teaser)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                        }
                        ForEach(viewModel.lessonSections) { section in
                            Section(section.title) {
                                ForEach(section.lessons) { lesson in
                                    NavigationLink(value: lesson) {
                                        LessonRowView(lesson: lesson, progress: viewModel.progress(for: lesson.id))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search lessons, words, characters…")
            .onChange(of: viewModel.searchText) { _ in viewModel.performSearch() }
            .navigationTitle("Lessons")
            .listStyle(.insetGrouped)
            .onAppear {
                if viewModel.lessonSections.isEmpty == false {
                    if reduceMotion {
                        appeared = true
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
                    }
                }
            }
            .onChange(of: viewModel.lessonSections.isEmpty) { isEmpty in
                if !isEmpty && !appeared {
                    if reduceMotion {
                        appeared = true
                    } else {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appeared = true }
                    }
                }
            }
            .navigationDestination(for: Lesson.self) { lesson in
                if lesson.type == .vocabulary {
                    VocabularyLessonView(lesson: lesson)
                } else {
                    AlphabetLessonView(lesson: lesson)
                }
            }
            .onAppear { viewModel.refreshProgress() }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if viewModel.lessonSections.isEmpty && !viewModel.isLoading {
                viewModel.loadLessons()
            }
        }
    }

    private func lessonsHeroRow(teaser: String) -> some View {
        HStack(alignment: .top, spacing: FidelTheme.spaceM) {
            Text("ሀ")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(FidelTheme.accent)
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text("Learn the Fidel")
                    .font(FidelTheme.headline)
                Text(teaser)
                    .font(FidelTheme.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FidelTheme.spaceM)
        .background(
            RoundedRectangle(cornerRadius: FidelTheme.radiusL)
                .fill(FidelTheme.cardBackground)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.8), value: appeared)
    }

    private var emptyStateView: some View {
        VStack(spacing: FidelTheme.spaceL) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 56))
                .foregroundStyle(FidelTheme.accent.opacity(0.6))
            Text("No Lessons Yet")
                .font(FidelTheme.title)
            Text("Lessons will appear here once loaded.\nPull down to refresh.")
                .font(FidelTheme.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(FidelTheme.spaceXL)
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let progress: LessonProgress?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundStyle(FidelTheme.accent)
                    Text(result.title)
                        .font(.headline)
                }
                if let subtitle = result.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let progress, progress.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch result.type {
        case .lesson: "book.fill"
        case .word: "textformat"
        case .fidelCharacter: "character"
        }
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let progress: LessonProgress?

    var body: some View {
        HStack(spacing: FidelTheme.spaceM) {
            Image(systemName: lesson.type == .alphabet ? "character" : "textformat")
                .font(.body)
                .foregroundStyle(FidelTheme.accent)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: FidelTheme.spaceXS) {
                Text(lesson.title)
                    .font(FidelTheme.headline)
                if let sub = lesson.subtitle, !sub.isEmpty {
                    Text(sub)
                        .font(FidelTheme.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let progress, progress.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(FidelTheme.success)
            }
        }
        .padding(.vertical, FidelTheme.spaceS)
    }
}

#Preview {
    LessonsView(progressService: SyncProgressService(getIsAuthenticated: { false }))
}
