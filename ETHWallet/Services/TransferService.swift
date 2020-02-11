import Foundation
import web3
import BigInt
import RxSwift

public struct TransferServiceConfig {
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt

    public init(gasPrice: BigUInt, gasLimit: BigUInt) {
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
    }
}

public protocol TransferServiceProtocol {

    func transfer(
        eth: Decimal,
        fromWallet wallet: EthereumAddress,
        toRecipient recipient: EthereumAddress,
        using account: EthereumAccount,
        config: TransferServiceConfig?
    ) -> Observable<String>
}

public struct TransferService: TransferServiceProtocol {
    private let client: EthereumClient
    private let contract: EthereumJSONContract
    private let config: TransferServiceConfig

    public init(
        client: EthereumClient,
        config: TransferServiceConfig = TransferServiceConfig(gasPrice: 12, gasLimit: 250_000)
    ) {
        guard let contract = EthereumJSONContract(
            json: Self.abi,
            address: EthereumAddress("0xcdAd167a8A9EAd2DECEdA7c8cC908108b0Cc06D1")
            )
            else { fatalError("Failed to initialise the contract with ABI \(Self.abi)") }

        self.client = client
        self.contract = contract
        self.config = config
    }

    public func transfer(
        eth: Decimal,
        fromWallet wallet: EthereumAddress,
        toRecipient recipient: EthereumAddress,
        using account: EthereumAccount,
        config: TransferServiceConfig? = nil
    ) -> Observable<String> {

        Observable.create { [contract] observer in

            let transferConfig = config ?? self.config

            do {
                let data = try contract.data(function: "transferToken", args: [
                    wallet.value,                                 // Wallet
                    "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE", // Token
                    recipient.value,                              // To
                    eth.toWei.description,                        // Amount
                    ""                                            // Data
                ])

                let tx = EthereumTransaction(
                    from: nil,
                    to: contract.address,
                    data: data,
                    gasPrice: transferConfig.gasPrice,
                    gasLimit: transferConfig.gasLimit
                )

                observer.onNext(tx)
                observer.onCompleted()

            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        }.flatMapLatest { [client] tx in
            client.rx.eth_sendRawTransaction(tx, withAccount: account)
        }
    }
}

extension TransferService {
    fileprivate static var abi: String {
        return """
        [
            {
                "constant": false,
                "inputs": [
                    {
                        "name": "_wallet",
                        "type": "address"
                    },
                    {
                        "name": "_token",
                        "type": "address"
                    },
                    {
                        "name": "_to",
                        "type": "address"
                    },
                    {
                        "name": "_amount",
                        "type": "uint256"
                    },
                    {
                        "name": "_data",
                        "type": "bytes"
                    }
                ],
                "name": "transferToken",
                "outputs": [],
                "payable": false,
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]
        """
    }
}
