import Foundation
import Architecture
import Models
import RxSwift
import API

func createEmailSignupReducer(api: UserAPI) -> Reducer<OnboardingState, EmailSignupAction> {
    
    return Reducer { state, action in
        switch action {
            
        case .goToLogin:
            state.route = OnboardingRoute.emailLogin
            
        case .cancel:
            state.route = AppRoute.onboarding
            
        case let .emailEntered(email):
            state.email = email
            
        case let .passwordEntered(password):
            state.password = password
            
        case .signupTapped:
            state.user = .loading
            return .empty
            
        case let .setError(error):
            state.user = .error(error)
        }
        
        return .empty
    }
}
