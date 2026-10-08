
//
//  CourseDetailViewModel.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import Foundation

@MainActor
final class CourseDetailViewModel: ObservableObject {
    @Published private(set) var course: Course?
    @Published var errorMessage: String?

    private let courseID: Int
    private let repository: CourseRepository

    init(courseID: Int, repository: CourseRepository) {
        self.courseID = courseID
        self.repository = repository
        course = repository.course(id: courseID)
    }

    func markCompleted(lessonID: Int) {
        do {
            course = try repository.markLessonCompleted(courseID: courseID, lessonID: lessonID)
        } catch {
            errorMessage = "Couldn't save your progress. Please try again."
        }
    }
}
