
//
//  LoginViewModel.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
   
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let authService = AuthService()
    private let onLoggedIn: (String) -> Void

    init(onLoggedIn: @escaping (String) -> Void) {
        self.onLoggedIn = onLoggedIn
    }

    var isEmailValid: Bool {
        email.range(of: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", options: .regularExpression) != nil
    }
    
    var isPasswordValid: Bool { password.count >= 6 }

    func login() async {
        guard isEmailValid else { errorMessage = "Please enter a valid email."; return }
        guard isPasswordValid else { errorMessage = "Password must be at least 6 characters."; return }

        isLoading = true
        errorMessage = nil
        do {
            let token = try await authService.login(email: email, password: password)
            onLoggedIn(token)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
