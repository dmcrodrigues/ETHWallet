import Foundation
import web3
import RxSwift
import RxFeedback

final class TransfersViewModel {
    private let system: Observable<State>
    private let disposeBag = DisposeBag()

    var transfers: Observable<[ERC20Events.Transfer]> {
        system.asObservable()
            .map { $0.transfers }
    }

    init(wallet: EthereumAddress, scheduler: ImmediateSchedulerType = MainScheduler.instance) {
        system = Observable.system(
            initialState: State(wallet: wallet),
            reduce: Self.reduce,
            scheduler: scheduler,
            feedback: [
                Feedbacks.whenLoading(scheduler: scheduler)
            ]
        ).share()
    }

    func viewDidLoad() {
        system
            .debug("[Transfers]")
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension TransfersViewModel {
    private enum Feedbacks {

        fileprivate typealias Feedback = (ObservableSchedulerContext<TransfersViewModel.State>) -> Observable<Event>

        fileprivate static func whenLoading(scheduler: ImmediateSchedulerType) -> Feedback {
            return { state in
                state
                    .filter { $0.status == .loading }
                    .flatMapLatest { state -> Observable<Event> in
                        Current.services.erc20.transfers(
                            toRecipient: state.wallet,
                            fromBlock: .Earliest,
                            toBlock: .Latest
                        )
                        .map(Event.didLoad)
                        .observeOn(scheduler)

                }
            }
        }
    }
}

extension TransfersViewModel {

    static func reduce(_ state: State, _ event: Event) -> State {
        switch event {
        case .didLoad(let transfers):
            return state
                .set(\.status, .loaded)
                .set(\.transfers, transfers)
        case .didFailLoad:
            fatalError("didFailLoad has not been implemented")
        }
    }
}

extension TransfersViewModel {
    struct State: Equatable, SetterProtocol {

        enum Status {
            case loading
            case loaded
        }

        let wallet: EthereumAddress

        var status: Status = .loading
        var transfers: [ERC20Events.Transfer] = []

    }

    enum Event {
        case didLoad([ERC20Events.Transfer])
        case didFailLoad
    }
}

extension ERC20Events.Transfer: Equatable {
    public static func == (lhs: ERC20Events.Transfer, rhs: ERC20Events.Transfer) -> Bool {
        lhs.log == rhs.log && lhs.from == rhs.from && lhs.to == rhs.to && lhs.value == rhs.value
    }
}
