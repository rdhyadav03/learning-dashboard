//
//  CourseListView.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//
import SwiftUI

struct CourseListView: View {
    @StateObject private var viewModel: CourseListViewModel
    private let repository: CourseRepository
    private let onLogout: () -> Void

    init(repository: CourseRepository, onLogout: @escaping () -> Void) {
        self.repository = repository
        self.onLogout = onLogout
        _viewModel = StateObject(wrappedValue: CourseListViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("My Courses")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out", action: onLogout)
                    }
                }
                .navigationDestination(for: Int.self) { courseID in
                    CourseDetailView(courseID: courseID, repository: repository)
                }
        }
        .task { await viewModel.loadIfNeeded() }
        .onAppear { viewModel.reloadFromStore() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading courses...")
        case .empty:
            messageView(title: "No courses yet", message: "Your courses will appear here.", button: "Refresh")
        case .failed(let message):
            messageView(title: "Couldn't load courses", message: message, button: "Try again")
        case .loaded:
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.isOffline {
                        Label("You're offline. Showing saved courses.", systemImage: "wifi.slash")
                            .font(.footnote)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
                    }
                    ForEach(viewModel.courses) { course in
                        NavigationLink(value: course.id) {
                            CourseRow(course: course)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .refreshable { await viewModel.load() }
        }
    }

    private func messageView(title: String, message: String, button: String) -> some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Text(message).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button(button) { Task { await viewModel.load() } }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct CourseRow: View {
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(course.title).font(.headline)
            Text(course.instructor).font(.subheadline).foregroundStyle(.secondary)
            ProgressView(value: Double(course.progress), total: 100)
            HStack {
                Text("\(course.progress)% complete")
                Spacer()
                Text("\(course.lessons.count) lessons")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("Continue")
                .font(.subheadline.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor, in: Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
