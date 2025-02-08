// RegistrationScreen.swift

import SwiftUI

struct RegistrationScreen: View {
    
    @EnvironmentObject private var model: BruinEatsModel
    @EnvironmentObject private var appState: AppState
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && (password.count >= 6 && password.count <= 10)
    }
    private func register() async {
        do {
            try await model.register(username: username, password: password)
            // Success - got 201 status
            appState.routes.append(.login)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var body: some View {
        VStack {
            Image("Logo") // Replace "YourLogoName" with the actual name of your logo asset
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100) // Adjust the size as needed
                            .padding(.top, 30)
                            .padding( .bottom, 20)

            // Header
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // Form fields
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            
            // Error message
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 8)
            }
            
            // Buttons
            HStack(spacing: 16) {

                
                Button(action: {
                    appState.routes.append(.login)
                }) {
                    Text("Login").frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.blue).cornerRadius(10)
                }.frame(maxWidth: .infinity)
                
                Button(action: {
                    Task {
                        await register()
                    }
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid).frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}
struct RegistrationScreenContainer: View {
    
    @StateObject private var model = BruinEatsModel()
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationStack(path: $appState.routes) {
            RegistrationScreen()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                        case .register:
                            RegistrationScreen()
                        case .login:
                            LoginScreen()
                    case .restaurantlistview:
                            Text("bruin eats list")
                    }
                }
        }
        .environmentObject(model)
        .environmentObject(appState)
    }
    
}

#Preview {
    RegistrationScreenContainer()
}
