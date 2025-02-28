import SwiftUI

struct LoginScreen: View {
    
    @EnvironmentObject private var model: BruinEatsModel
    @EnvironmentObject private var appState: AppState
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && (password.count >= 6 && password.count <= 10)
    }
    
    private func login() async {
        do {
            let response = try await model.login(username: username, password: password)
            if let error = response["error"], error == "true" {
                errorMessage = response["reason"] ?? "Login failed"
            } else {
                appState.routes.append(.restaurantlistview)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var body: some View {

    VStack {
        // Logo at the top
        Image("Logo") // Replace "YourLogoName" with your logo asset name
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .padding(.top, 40)
            .padding(.bottom, 20)
        
        // Header
        Text("Login")
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
        HStack(spacing: 16) {
            
            Button(action: {
//                appState.routes.append(.register)
                appState.routes.removeLast()

            }) {
                Text("Register").frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue).cornerRadius(10)
            }.frame(maxWidth: .infinity)            .padding(.horizontal, 24)
                .padding(.top, 16)
            // Login Button
            Button(action: {
                Task {
                    await login()
                }
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.frame(maxWidth: .infinity)
            .disabled(!isFormValid)
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        
        Spacer()
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .navigationBarHidden(true)
}

}

#Preview {
    NavigationStack {
        LoginScreen()
            .environmentObject(BruinEatsModel())
            .environmentObject(AppState())
    }
}
