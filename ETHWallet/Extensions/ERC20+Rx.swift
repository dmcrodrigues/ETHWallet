import RxSwift
import web3

extension Reactive where Base == ERC20 {

    public func transferEventsTo(
        recipient: EthereumAddress,
        fromBlock: EthereumBlock,
        toBlock: EthereumBlock
    ) -> Observable<[ERC20Events.Transfer]> {
        Observable.create { [base] observer in
            base.transferEventsTo(recipient: recipient, fromBlock: .Earliest, toBlock: .Latest) { error, transfers in
                if let error = error {
                    observer.onError(error)
                } else if let transfers = transfers {
                    observer.onNext(transfers)
                    observer.onCompleted()
                } else {
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }
}

extension ERC20: ReactiveCompatible {}
