import Foundation
import BigInt
import RxSwift
import RxSwiftExt
import RxFeedback
import web3

public final class HomeViewModel {
    private let system: Observable<State>
    private let disposeBag = DisposeBag()

    var balance: Observable<String> {
        system.asObservable()
            .map { state in state.balance.quotientAndRemainder(dividingBy: BigUInt(1000000000000000000)) }
            .map { result in
                "\(result.quotient).\(result.remainder) ETH"
            }
    }

    init(walletService: WalletServiceProtocol, storage: EthereumKeyStorageProtocol, router: @escaping Router<Route>, scheduler: ImmediateSchedulerType = MainScheduler.instance) {
        system = Observable.system(
            initialState: State.initial,
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
            .debug("System")
            .subscribe()
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
            }
        }

        fileprivate static func whenLoadingBalance(walletService: WalletServiceProtocol, scheduler: ImmediateSchedulerType) -> Feedback {
            return { state in
                state
                    .filterMap { state -> FilterMap<EthereumAccount> in
                        guard
                            state.status == .loadingBalance,
                            let account = state.account
                            else { return .ignore }

                        return .map(account)
                    }
                    .flatMapLatest { account -> Observable<Event> in
                        walletService.balance(of: EthereumAddress(account.address), block: .Latest)
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
            return State(status: .ready, balance: balance)
        case .didFailLoadBalance:
            fatalError()
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

        var status: Status
        var account: EthereumAccount?
        var balance: BigUInt = 0

        static var initial: State {
            return State(status: .loadingAccount)
        }
    }

    enum Event {
        case didLoadAccount(EthereumAccount)
        case didFailLoadAccount
        case didLoadBalance(BigUInt)
        case didFailLoadBalance
    }

    enum Input {
        case refresh
        case didSelectItem(index: Int)
    }

    enum Route {
        case loadAccount(completion: (String?) -> Void)
    }
}

extension EthereumAccount: Equatable {
    public static func == (lhs: EthereumAccount, rhs: EthereumAccount) -> Bool {
        lhs.address == rhs.address && lhs.publicKey == rhs.publicKey
    }
}
