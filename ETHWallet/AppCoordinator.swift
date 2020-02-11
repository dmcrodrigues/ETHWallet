import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private lazy var navigation = UINavigationController()

    public init(window: UIWindow) {
        self.window = window
    }

    public func start() {
        navigation.setViewControllers([HomeBuilder.makeHome(with: self.router)], animated: false)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }

    private func router(route: HomeViewModel.Route) {
        switch route {
        case .loadAccount(let completion):
            navigation.present(
                HomeBuilder.makeLoadAccount(completion: completion), animated: true, completion: nil
            )
        case .viewTransfers(let wallet):
            navigation.pushViewController(TransfersBuilder.make(wallet: wallet), animated: true)
        }
    }
}

