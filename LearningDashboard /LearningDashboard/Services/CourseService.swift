import Foundation
import Network

protocol CourseService {
    func fetchCourses() async throws -> [Course]
}

// JSON shape from the assignment.
private struct CourseResponse: Decodable {
    let id: Int
    let title: String
    let instructor: String
    let progress: Int
    let lessons: Int
}

// Mock API: waits a bit, fails when the device is offline, otherwise reads courses.json.
struct MockCourseService: CourseService {
    func fetchCourses() async throws -> [Course] {
        try await Task.sleep(nanoseconds: 800_000_000)

        guard NetworkMonitor.shared.isConnected else {
            throw URLError(.notConnectedToInternet)
        }
        guard let url = Bundle.main.url(forResource: "courses", withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        let items = try JSONDecoder().decode([CourseResponse].self, from: Data(contentsOf: url))
        return items.map(makeCourse)
    }

    //The API only sends a lesson count, so build the lesson list from it.
    private func makeCourse(from item: CourseResponse) -> Course {
        let completedCount = Int((Double(item.progress) / 100 * Double(item.lessons)).rounded())

        let lessons = (0..<item.lessons).map { index -> Lesson in
            let title =  "Lesson \(index + 1)"
            return Lesson(id: index + 1, title: title, isCompleted: index < completedCount)
        }
        return Course(id: item.id, title: item.title, instructor: item.instructor, lessons: lessons)
    }
}

// Detect if the device has internet.
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private(set) var isConnected = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
        }
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
    }
}
