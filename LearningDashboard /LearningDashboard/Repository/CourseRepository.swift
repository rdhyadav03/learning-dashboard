//
//  CourseRepository.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 07/10/26.
//

import Foundation

struct LoadResult {
    let courses: [Course]
    let isFromCache: Bool
}


@MainActor
final class CourseRepository {
    private let service: CourseService
    private let store: CourseStore

    init(service: CourseService, store: CourseStore) {
        self.service = service
        self.store = store
    }

    // calling API first. If it fails then cached courses.
    func loadCourses() async throws -> LoadResult {
        do {
            let remote = try await service.fetchCourses()
            let courses = keepingLocalProgress(remote)
            try? store.save(courses)   // a cache write failure shouldn't hide fresh data
            return LoadResult(courses: courses, isFromCache: false)
        } catch {
            let cached = store.loadAll()
            if cached.isEmpty { throw error }
            return LoadResult(courses: cached, isFromCache: true)
        }
    }

    func cachedCourses() -> [Course] {
        store.loadAll()
    }

    func course(id: Int) -> Course? {
        store.course(id: id)
    }

    func markLessonCompleted(courseID: Int, lessonID: Int) throws -> Course {
        
        try store.markLessonCompleted(courseID: courseID, lessonID: lessonID)
    }

    // update already completed when the list is refreshed.
    private func keepingLocalProgress(_ remote: [Course]) -> [Course] {
        let completedIDs = Set(
            store.loadAll()
                .flatMap(\.lessons)
                .filter(\.isCompleted)
                .map(\.id)
        )

        return remote.map { course in
            var course = course
            for i in course.lessons.indices {
                course.lessons[i].isCompleted = completedIDs.contains(course.lessons[i].id)
            }
            return course
        }
    }
}
