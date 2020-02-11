import UIKit
import web3

struct HomeBuilder {

    static func makeHome(with router: @escaping Router<HomeViewModel.Route>) -> UIViewController {
        let viewModel = HomeViewModel(
            walletAddress: EthereumAddress("0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB"),
            walletService: Current.services.wallet,
            storage: Current.storage,
            router: router
        )

        return HomeViewController(viewModel: viewModel)
    }

    static func makeLoadAccount(completion: @escaping (String?) -> Void) -> UIViewController {

        let preLoadedPrivateKey = ProcessInfo.processInfo.environment["PRIVATE_KEY"]

        let message = preLoadedPrivateKey == nil
            ? "load_account.message.default".localized
            : "load_account.message.preloaded_key".localized

        let alert = UIAlertController(title: "load_account.title".localized, message: message, preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "load_account.input.placeholder".localized
            textField.text = preLoadedPrivateKey
        }

        alert.addAction(
            UIAlertAction(
                title: "load_account.confirm_button.title".localized,
                style: .default,
                handler: { action in
                    completion(alert.textFields?[0].text)
                }
            )
        )

        return alert
    }
}
