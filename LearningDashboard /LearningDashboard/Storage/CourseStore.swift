
//
//  CourseStore.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import Foundation
import RealmSwift

enum StoreError: Error { case notFound }

@MainActor
final class CourseStore {
    private let config: Realm.Configuration

    init(config: Realm.Configuration = .defaultConfiguration) {
        self.config = config
    }

    func loadAll() -> [Course] {
        guard let realm = try? Realm(configuration: config) else { return [] }
        return realm.objects(RealmCourse.self)
            .sorted(byKeyPath: "order")
            .map { $0.toCourse() }
    }

    func course(id: Int) -> Course? {
        let realm = try? Realm(configuration: config)
        return realm?.object(ofType: RealmCourse.self, forPrimaryKey: id)?.toCourse()
    }

    //Saving course
    func save(_ courses: [Course]) throws {
        let realm = try Realm(configuration: config)
        try realm.write {
            realm.delete(realm.objects(RealmCourse.self))
            for (index, course) in courses.enumerated() {
                realm.add(RealmCourse(course: course, order: index))
            }
        }
    }

    //Making Course complete
    func markLessonCompleted(courseID: Int, lessonID: Int) throws -> Course {
        let realm = try Realm(configuration: config)
        guard let course = realm.object(ofType: RealmCourse.self, forPrimaryKey: courseID),
              let lesson = course.lessons.first(where: { $0.id == lessonID }) else {
            throw StoreError.notFound
        }
        try realm.write { lesson.isCompleted = true }
        return course.toCourse()
    }
}
