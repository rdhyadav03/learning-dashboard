
//
//  CourseListViewModel.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import Foundation

@MainActor
final class CourseListViewModel: ObservableObject {
   
    enum State: Equatable {
        case idle, loading, loaded, empty
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var courses: [Course] = []
    @Published private(set) var isOffline = false

    private let repository: CourseRepository

    init(repository: CourseRepository) {
        self.repository = repository
    }

    func loadIfNeeded() async {
        if state == .idle { await load() }
    }

    func load() async {
        if courses.isEmpty { state = .loading }
        do {
            let result = try await repository.loadCourses()
            courses = result.courses
            isOffline = result.isFromCache
            state = courses.isEmpty ? .empty : .loaded
        } catch {
            if courses.isEmpty {
                state = .failed(Self.message(for: error))
            }
        }
    }

    // Called when coming back from the details screen so progress is up to date.
    func reloadFromStore() {
        guard state == .loaded else { return }
        courses = repository.cachedCourses()
    }

    private static func message(for error: Error) -> String {
        if (error as? URLError)?.code == .notConnectedToInternet {
            return "No internet connection. Please try again."
        }
        return "Something went wrong. Please try again."
    }
}
