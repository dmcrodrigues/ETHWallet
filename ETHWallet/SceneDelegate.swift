import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    let window: UIWindow

    if let windowScene = scene as? UIWindowScene {
      window = UIWindow(windowScene: windowScene)
    } else {
      window = UIWindow(frame: UIScreen.main.bounds)
      window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    self.window = window

    AppCoordinator(window: window).start()
  }
}
