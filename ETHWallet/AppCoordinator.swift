import UIKit

final class AppCoordinator {
  private let window: UIWindow

  public init(window: UIWindow) {
    self.window = window
  }

  public func start() {
    window.rootViewController = HomeBuilder.makeHome(with: self.router)
    window.makeKeyAndVisible()
  }

    private func router(route: HomeViewModel.Route) {
        switch route {
        case .loadAccount(let completion):
            self.window.rootViewController?.present(
                HomeBuilder.makeLoadAccount(completion: completion), animated: true, completion: nil
            )
        }
    }
}
