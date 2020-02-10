import Foundation
import web3
import BigInt
import RxSwift

public protocol WalletServiceProtocol {
    func balance(of address: EthereumAddress, block: EthereumBlock) -> Observable<BigUInt>
}

public struct WalletService: WalletServiceProtocol {
    private let client: EthereumClient

    init(client: EthereumClient) {
        self.client = client
    }

    public func balance(of address: EthereumAddress, block: EthereumBlock) -> Observable<BigUInt> {
        client.rx.eth_getBalance(address: address, block: block)
    }
}
