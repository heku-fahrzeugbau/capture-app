import Foundation
import AuthenticationServices

class GoogleAuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var isAuthenticated = false
    @Published var authToken: String?
    @Published var userEmail: String?
    @Published var errorMessage: String?
    
    // TODO: Set these from GoogleService-Info.plist
    private let clientID = "YOUR_GOOGLE_CLIENT_ID"
    private let redirectURI = "de.heku.capture://oauth"
    private let scope = "https://www.googleapis.com/auth/drive.file"
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    func authenticate() {
        let authURL = buildAuthURL()
        
        let session = ASWebAuthenticationSession(
            url: authURL,
            callbackURLScheme: "de.heku.capture"
        ) { [weak self] url, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Auth failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let url = url, let code = self?.extractCode(from: url) else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No auth code received"
                }
                return
            }
            
            Task {
                await self?.exchangeCodeForToken(code)
            }
        }
        
        session.presentationContextProvider = self
        session.start()
    }
    
    private func buildAuthURL() -> URL {
        var components = URLComponents(string: "https://accounts.google.com/o/oauth2/v2/auth")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "access_type", value: "offline")
        ]
        return components.url!
    }
    
    private func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        return code
    }
    
    private func exchangeCodeForToken(_ code: String) async {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        
        let body = [
            "code": code,
            "client_id": clientID,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"
            // TODO: Add client_secret (keep secure!)
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(TokenResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.authToken = response.access_token
                self.isAuthenticated = true
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Token exchange failed: \(error.localizedDescription)"
            }
        }
    }
    
    func logout() {
        authToken = nil
        isAuthenticated = false
        userEmail = nil
    }
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
    let expires_in: Int
    let refresh_token: String?
}
