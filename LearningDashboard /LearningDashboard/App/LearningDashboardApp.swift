
//
//  LearningDashboardApp.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//
import SwiftUI

@main
struct LearningDashboardApp: App {
    @State private var isLoggedIn = TokenStorage.read() != nil
    private let repository = CourseRepository(service: MockCourseService(), store: CourseStore())

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                CourseListView(repository: repository) {
                    TokenStorage.delete()
                    isLoggedIn = false
                }
            } else {
                LoginView { tok in
                    TokenStorage.save(tok)
                    isLoggedIn = true
                }

            }
        }
    }
}
