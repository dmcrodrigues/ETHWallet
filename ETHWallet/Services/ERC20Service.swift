import Foundation
import web3
import BigInt
import RxSwift

public protocol ERC20ServiceProtocol {
    func transfers(
        toRecipient recipient: EthereumAddress,
        fromBlock earliestBlock: EthereumBlock,
        toBlock latestBlock: EthereumBlock
    ) -> Observable<[ERC20Events.Transfer]>
}

public struct ERC20Service: ERC20ServiceProtocol {
    private let client: ERC20

    public init(client: EthereumClient) {
        self.client = ERC20(client: client)
    }

    public func transfers(
        toRecipient recipient: EthereumAddress,
        fromBlock earliestBlock: EthereumBlock,
        toBlock latestBlock: EthereumBlock
    ) -> Observable<[ERC20Events.Transfer]> {
        client.rx.transferEventsTo(recipient: recipient, fromBlock: earliestBlock, toBlock: latestBlock)
    }
}
