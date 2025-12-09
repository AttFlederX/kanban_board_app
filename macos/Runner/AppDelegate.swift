import Cocoa
import FlutterMacOS
import AppAuth

@main
class AppDelegate: FlutterAppDelegate {
  private var currentAuthorizationFlow: OIDExternalUserAgentSession?
  
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Register method channel for custom macOS Google Sign-in
    let channel = FlutterMethodChannel(
      name: "com.kanban_board_app/macos_auth",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "signInWithGoogle" {
        self?.handleGoogleSignIn(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func handleGoogleSignIn(result: @escaping FlutterResult) {
    guard let clientId = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
          let clientSecret = Bundle.main.object(forInfoDictionaryKey: "GIDClientSecret") as? String,
          let reversedClientId = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
          let urlScheme = (reversedClientId.first?["CFBundleURLSchemes"] as? [String])?.first else {
      result(FlutterError(code: "CONFIG_ERROR", message: "Missing client ID or secret", details: nil))
      return
    }
    
    let issuer = URL(string: "https://accounts.google.com")!
    let redirectURI = URL(string: "\(urlScheme):/oauth2redirect/google")!
    
    // Discover OAuth endpoints
    OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { [weak self] configuration, error in
      guard let self = self, let config = configuration else {
        result(FlutterError(code: "DISCOVERY_ERROR", message: error?.localizedDescription ?? "Unknown error", details: nil))
        return
      }
      
      // Build authentication request
      let request = OIDAuthorizationRequest(
        configuration: config,
        clientId: clientId,
        clientSecret: clientSecret,
        scopes: ["openid", "profile", "email"],
        redirectURL: redirectURI,
        responseType: OIDResponseTypeCode,
        additionalParameters: nil
      )
      
      // Present authentication UI
      guard let window = self.mainFlutterWindow else {
        result(FlutterError(code: "WINDOW_ERROR", message: "No main window", details: nil))
        return
      }
      
      self.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: window) { authState, error in
        if let error = error {
          result(FlutterError(code: "AUTH_ERROR", message: error.localizedDescription, details: nil))
          return
        }
        
        guard let authState = authState else {
          result(FlutterError(code: "AUTH_ERROR", message: "No auth state", details: nil))
          return
        }
        
        // Return the ID token to Flutter
        if let idToken = authState.lastTokenResponse?.idToken {
          result(["idToken": idToken])
        } else {
          result(FlutterError(code: "TOKEN_ERROR", message: "No ID token", details: nil))
        }
      }
    }
  }
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
