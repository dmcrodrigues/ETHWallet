import UIKit
import RxSwift
import RxDataSources

final class TransfersViewController: UIViewController {
    private let viewModel: TransfersViewModel
    private let disposeBag = DisposeBag()

    private let tableView = UITableView()

    init(viewModel: TransfersViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        tableView.register(TransferCell.self, forCellReuseIdentifier: String(describing: TransferCell.self))
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let contentView = UIView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])

        self.view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        viewModel.viewDidLoad()

        viewModel.transfers.bind(
            to: tableView.rx.items(cellIdentifier: String(describing: TransferCell.self), cellType: TransferCell.self)
        ) { _, transfer, cell in
            cell.fromLabel.text = String(format: "transfers.cell.from.label".localized, transfer.from.value)
            cell.toLabel.text = String(format: "transfers.cell.to.label".localized, transfer.to.value)
            cell.valueLabel.text = String(format: "transfers.cell.value.label".localized, transfer.value.toEther.description)
        }.disposed(by: disposeBag)
    }
}

