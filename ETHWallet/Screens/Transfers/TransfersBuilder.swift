import UIKit
import web3

struct TransfersBuilder {
    static func make(wallet: EthereumAddress) -> UIViewController {
        let viewModel = TransfersViewModel(wallet: wallet)
        return TransfersViewController(viewModel: viewModel)
    }
}
