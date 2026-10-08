
//
//  LoginView.swift
//  LearningDashboard
//
//  Created by Radheshyam Yadav on 08/10/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(onLoggedIn: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(onLoggedIn: onLoggedIn))
    }

    var body: some View {
        VStack(spacing: 10) {
            Text("Learning Dashboard").font(.largeTitle.bold())

            TextField("Email", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let message = viewModel.errorMessage {
                Text(message).font(.callout).foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.login() }
            } label: {
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Login").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isLoading)
        }
        .padding(24)
        .frame(maxWidth: 420)
    }
}
