import UIKit
import web3

struct HomeBuilder {

    static func makeHome(with router: @escaping Router<HomeViewModel.Route>) -> UIViewController {
        let viewModel = HomeViewModel(
            walletAddress: EthereumAddress("0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB"),
            transferRecipient: EthereumAddress("0x3c1bd6b420448cf16a389c8b0115ccb3660bb854"),
            walletService: Current.services.wallet,
            storage: Current.storage,
            router: router
        )

        return HomeViewController(viewModel: viewModel)
    }

    static func makeLoadAccount(completion: @escaping (String?) -> Void) -> UIViewController {

        let preLoadedPrivateKey = ProcessInfo.processInfo.environment["PRIVATE_KEY"]

        let message = preLoadedPrivateKey?.isEmpty ?? true
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
                    assert(alert.textFields?[0].text?.isEmpty == false, "Private key cannot be empty")
                    completion(alert.textFields?[0].text)
                }
            )
        )

        return alert
    }
}
