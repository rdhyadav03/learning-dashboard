import XCTest
import RealmSwift
@testable import LearningDashboard

private final class FakeCourseService: CourseService {
    var result: Result<[Course], Error>
    init(_ result: Result<[Course], Error>) {
        self.result = result
    }
    func fetchCourses() async throws -> [Course] {
        try result.get()
    }
}

@MainActor
final class CourseRepositoryTests: XCTestCase {
    
    private let course = Course(id: 1, title: "Python", instructor: "John", lessons: [
        Lesson(id: 1, title: "Lesson 1", isCompleted: true),
        Lesson(id: 2, title: "Lesson 2", isCompleted: false)
    ])

    private func makeRepository(service: FakeCourseService) -> CourseRepository {
        let config = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)
        return CourseRepository(service: service, store: CourseStore(config: config))
    }

    func test_progress_isCompletedLessonsOverTotal() {
        XCTAssertEqual(course.progress, 50)
        XCTAssertEqual(Course(id: 2, title: "Empty", instructor: "-", lessons: []).progress, 0)
    }

    // The offline requirement: load once, lose the network, data is still there.
    func test_loadCourses_whenOfflineAfterFirstLoad_returnsCachedCourses() async throws {
        let service = FakeCourseService(.success([course]))
        let repository = makeRepository(service: service)
        _ = try await repository.loadCourses()

        service.result = .failure(URLError(.notConnectedToInternet))
        let result = try await repository.loadCourses()

        XCTAssertTrue(result.isFromCache)
        XCTAssertEqual(result.courses.map(\.title), ["Python"])
    }

    func test_markLessonCompleted_updatesProgressAndPersists() async throws {
        let repository = makeRepository(service: FakeCourseService(.success([course])))
        _ = try await repository.loadCourses()

        let updated = try repository.markLessonCompleted(courseID: 1, lessonID: 2)

        XCTAssertEqual(updated.progress, 100)
        XCTAssertEqual(repository.course(id: 1)?.progress, 100)
    }

    func test_refresh_keepsLessonsCompletedLocally() async throws {
        let repository = makeRepository(service: FakeCourseService(.success([course])))
        _ = try await repository.loadCourses()
        _ = try repository.markLessonCompleted(courseID: 1, lessonID: 2)

        let refreshed = try await repository.loadCourses()   // API still says lesson 2 is pending

        XCTAssertEqual(refreshed.courses.first?.progress, 100)
    }
}
