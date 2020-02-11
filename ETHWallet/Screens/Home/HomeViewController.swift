import UIKit
import RxSwift

public final class HomeViewController: UIViewController {
    private lazy var walletBalanceTitle = UILabel()
    private lazy var walletBalanceValue = UILabel()
    private lazy var sendButton = UIButton()
    private lazy var viewTransfers = UIButton()

    private let viewModel: HomeViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        let view = UIView()

        let wallStack = UIStackView(arrangedSubviews: [walletBalanceTitle, walletBalanceValue])
        wallStack.axis = .vertical
        wallStack.alignment = .center
        wallStack.translatesAutoresizingMaskIntoConstraints = false

        walletBalanceTitle.translatesAutoresizingMaskIntoConstraints = false
        walletBalanceValue.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        wallStack.setCustomSpacing(20, after: walletBalanceValue)
        wallStack.addArrangedSubview(sendButton)

        view.addSubview(wallStack)

        NSLayoutConstraint.activate([
            wallStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            wallStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            wallStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        viewTransfers.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(viewTransfers)

        NSLayoutConstraint.activate([
            viewTransfers.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            viewTransfers.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            viewTransfers.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        self.view = view
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewDidLoad()

        view.backgroundColor = .white

        walletBalanceTitle.text = "home.wallet_balance.title".localized

        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.setTitle("Send 0.01 ETH", for: .normal)

        viewTransfers.setTitleColor(.blue, for: .normal)
        viewTransfers.setTitle("home.view_transfers_button.title".localized, for: .normal)

        setupBindings()
    }

    private func setupBindings() {
        viewModel.balance.bind(to: walletBalanceValue.rx.text)
            .disposed(by: disposeBag)

        sendButton.rx.tap
            .map { HomeViewModel.Input.sendEth }
            .bind(to: viewModel.inputsSubject)
            .disposed(by: disposeBag)

        viewTransfers.rx.tap
            .map { HomeViewModel.Input.viewTransfers }
            .bind(to: viewModel.inputsSubject)
            .disposed(by: disposeBag)
    }
}
