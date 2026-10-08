//
//  RealmModels.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//
import RealmSwift

final class RealmLesson: EmbeddedObject {
    @Persisted var id: Int
    @Persisted var title: String
    @Persisted var isCompleted: Bool
}

final class RealmCourse: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var title: String
    @Persisted var instructor: String
    @Persisted var order: Int
    @Persisted var lessons: List<RealmLesson>

    convenience init(course: Course, order: Int) {
        self.init()
        id = course.id
        title = course.title
        instructor = course.instructor
        self.order = order
        for lesson in course.lessons {
            let item = RealmLesson()
            item.id = lesson.id
            item.title = lesson.title
            item.isCompleted = lesson.isCompleted
            lessons.append(item)
        }
    }

    func toCourse() -> Course {
        Course(id: id,
               title: title,
               instructor: instructor,
               lessons: lessons.map { Lesson(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) })
    }
}
