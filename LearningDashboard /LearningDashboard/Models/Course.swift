//
//  Course.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 07/10/26.
//


import Foundation

struct Lesson: Identifiable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

struct Course: Identifiable {
    let id: Int
    let title: String
    let instructor: String
    var lessons: [Lesson]

    var completedLessons: Int { lessons.filter { $0.isCompleted }.count }

   
    var progress: Int {
        guard !lessons.isEmpty else { return 0 }
        return Int((Double(completedLessons) / Double(lessons.count) * 100).rounded())
    }
}
