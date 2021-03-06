import Foundation
import BigInt
import RxSwift
import RxSwiftExt
import RxCocoa
import RxFeedback
import web3

final class HomeViewModel {
    private let system: Observable<State>
    private let router: Router<Route>
    private let disposeBag = DisposeBag()

    let inputsSubject = PublishRelay<Input>()

    var balance: Observable<String> {
        system.asObservable()
            .map { state in "\(state.balance.toEther) ETH" }
    }

    init(
        walletAddress: EthereumAddress,
        transferRecipient: EthereumAddress,
        walletService: WalletServiceProtocol,
        storage: EthereumKeyStorageProtocol,
        router: @escaping Router<Route>,
        scheduler: ImmediateSchedulerType = MainScheduler.instance
    ) {
        self.router = router

        self.system = Observable.system(
            initialState: State(wallet: walletAddress, transferRecipient: transferRecipient),
            reduce: Self.reduce,
            scheduler: scheduler,
            feedback: [
                Feedbacks.whenLoadingAccount(storage: storage, router: router, scheduler: scheduler),
                Feedbacks.whenLoadingBalance(walletService: walletService, scheduler: scheduler)
            ]
        ).share()
    }

    func viewDidLoad() {
        system
            .debug("[Home]")
            .subscribe()
            .disposed(by: disposeBag)

        inputsSubject.asObservable()
            .withLatestFrom(system, resultSelector: { ($0, $1) })
            .subscribe(onNext: { [disposeBag, router] input, state in
                switch input {
                case .viewTransfers:
                    router(.viewTransfers(wallet: state.wallet))
                case .sendEth:
                    guard let account = state.account else { return }

                    Current.services.transfer.transfer(
                        eth: Decimal(0.01),
                        fromWallet: state.wallet,
                        toRecipient: state.transferRecipient,
                        using: account,
                        config: nil
                        )
                        .subscribe(onNext: { block in
                            print("Transfer block: \(block)")
                        })
                        .disposed(by: disposeBag)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    private enum Feedbacks {

        fileprivate typealias Feedback = (ObservableSchedulerContext<HomeViewModel.State>) -> Observable<Event>

        fileprivate static func whenLoadingAccount(
            storage: EthereumKeyStorageProtocol,
            router: @escaping Router<Route>,
            scheduler: ImmediateSchedulerType
        ) -> Feedback {
            return { state in
                state.filter { $0.status == .loadingAccount }
                    .flatMapLatest { _ -> Observable<Event> in
                        loadAccount(from: storage)
                            .catchError { _ in
                                requestAccount(with: storage, router)
                            }
                    }
                    .observeOn(scheduler)
            }
        }

        fileprivate static func whenLoadingBalance(walletService: WalletServiceProtocol, scheduler: ImmediateSchedulerType) -> Feedback {
            return { state in
                state
                    .filter { $0.status == .loadingBalance }
                    .flatMapLatest { state -> Observable<Event> in
                        walletService.balance(of: state.wallet, block: .Latest)
                            .observeOn(scheduler)
                            .map(Event.didLoadBalance)
                    }
            }
        }

        private static func loadAccount(from storage: EthereumKeyStorageProtocol) -> Observable<Event> {

            enum LoadError: Error {
                case unavailable
            }

            return Observable.create { observer in
                do {
                    let account = try EthereumAccount(keyStorage: storage)
                    observer.onNext(.didLoadAccount(account))
                    observer.onCompleted()
                } catch {
                    observer.onError(LoadError.unavailable)
                }

                return Disposables.create()
            }
        }

        private static func requestAccount(
            with storage: EthereumKeyStorageProtocol,
            _ router: @escaping Router<Route>
        ) -> Observable<Event> {
            Observable.create { observer in
                router(.loadAccount(completion: { privateKey in
                    guard let data = privateKey?.web3.hexData
                        else { return observer.onNext(Event.didFailLoadAccount) }

                    do {
                        try storage.storePrivateKey(key: data)
                        let account = try EthereumAccount(keyStorage: storage)

                        observer.onNext(.didLoadAccount(account))
                        observer.onCompleted()
                    } catch {
                        return observer.onNext(Event.didFailLoadAccount)
                    }
                }))
                return Disposables.create()
            }
        }
    }
}

extension HomeViewModel {

    static func reduce(_ state: State, _ event: Event) -> State {
        switch event {
        case .didLoadBalance(let balance):
            return state
                .set(\.balance, balance)
                .set(\.status, .ready)
        case .didFailLoadBalance:
            fatalError("didFailLoadBalance has not been implemented")
        case .didLoadAccount(let account):
            return state
                .set(\.account, account)
                .set(\.status, .loadingBalance)
        case .didFailLoadAccount:
            return state.set(\.status, .ready)
        }
    }
}

extension HomeViewModel {
    struct State: Equatable, SetterProtocol {

        enum Status {
            case loadingAccount
            case loadingBalance
            case ready
        }

        let wallet: EthereumAddress
        let transferRecipient: EthereumAddress

        var status: Status = .loadingAccount
        var account: EthereumAccount?
        var balance: BigUInt = 0
    }

    enum Event {
        case didLoadAccount(EthereumAccount)
        case didFailLoadAccount
        case didLoadBalance(BigUInt)
        case didFailLoadBalance
    }

    enum Input {
        case viewTransfers
        case sendEth
    }

    enum Route {
        case loadAccount(completion: (String?) -> Void)
        case viewTransfers(wallet: EthereumAddress)
    }
}

extension EthereumAccount: Equatable {
    public static func == (lhs: EthereumAccount, rhs: EthereumAccount) -> Bool {
        lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
    }
}
