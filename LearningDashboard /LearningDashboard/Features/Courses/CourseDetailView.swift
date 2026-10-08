
//
//  CourseDetailView.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import SwiftUI

struct CourseDetailView: View {
    @StateObject private var viewModel: CourseDetailViewModel

    init(courseID: Int, repository: CourseRepository) {
        _viewModel = StateObject(wrappedValue: CourseDetailViewModel(courseID: courseID, repository: repository))
    }

    var body: some View {
        Group {
            if let course = viewModel.course {
                List {
                    Section {
                        Text("Progress: \(course.progress)%").font(.headline)
                        ProgressView(value: Double(course.progress), total: 100)
                    }
                    Section("Lessons") {
                        ForEach(course.lessons) { lesson in
                            HStack {
                                Image(systemName: lesson.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(lesson.isCompleted ? Color.green : Color.gray)
                                Text(lesson.title)
                                Spacer()
                                if lesson.isCompleted {
                                    Text("Completed").font(.caption).foregroundStyle(.green)
                                } else {
                                    Button("Mark complete") { viewModel.markCompleted(lessonID: lesson.id) }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(course.title)
            } else {
                Text("Course not found").foregroundStyle(.secondary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil },
                                             set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
