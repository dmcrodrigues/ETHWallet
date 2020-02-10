import Foundation
import RxSwift
import web3
import BigInt

// Ideally should be `EthereumClientProtocol` but `ERC20` is not relying on the abstraction and instead uses the
// concrete type directly
extension Reactive where Base == EthereumClient {

    public func eth_getBalance(address: EthereumAddress, block: EthereumBlock) -> Observable<BigUInt> {
        Observable.create { [base] observer in
            base.eth_getBalance(address: address.value, block: block) { error, balance in
                if let error = error {
                    observer.onError(error)
                } else if let balance = balance {
                    observer.onNext(balance)
                    observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }

    public func eth_sendRawTransaction(
        _ transaction: EthereumTransaction,
        withAccount account: EthereumAccount
    ) -> Observable<String> {
        Observable.create { [base] observer in
            base.eth_sendRawTransaction(transaction, withAccount: account) { error, block in
                if let error = error {
                    observer.onError(error)
                } else if let block = block {
                    observer.onNext(block)
                    observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }
}

extension EthereumClient: ReactiveCompatible {}
