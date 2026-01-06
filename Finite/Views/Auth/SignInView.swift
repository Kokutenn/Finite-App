import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    private var theme: Theme {
        Theme(appearance: appearanceManager)
    }
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and tagline
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(theme.logoName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                        
                        Text("FINITE")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryText)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Description
                VStack(spacing: 12) {
                    Text("This app won't track your habits")
                        .foregroundColor(theme.tertiaryText)
                    Text("or celebrate your progress.")
                        .foregroundColor(theme.tertiaryText)
                    Text("")
                    Text("It will constantly remind you")
                        .foregroundColor(theme.tertiaryText)
                    Text("how little time you have left.")
                        .foregroundColor(theme.primaryText)
                        .fontWeight(.semibold)
                    Text("")
                    Text("That's the point.")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                
                Spacer()
                
                // Sign in button
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.email]
                    },
                    onCompletion: { result in
                        Task {
                            await authViewModel.handleSignInWithApple(result)
                        }
                    }
                )
                .signInWithAppleButtonStyle(appearanceManager.isDarkMode ? .white : .black)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 8)
                }
                
                #if DEBUG
                // Simulator bypass for testing
                Button {
                    Task {
                        await authViewModel.simulatorSignIn()
                    }
                } label: {
                    Text("Skip Sign In (Simulator Only)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                }
                #endif
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .overlay(DebugThemeToggle())
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceManager.shared)
}
