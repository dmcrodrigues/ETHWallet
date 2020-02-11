import UIKit

final class TransferCell: UITableViewCell {
    let toLabel = UILabel()
    let fromLabel = UILabel()
    let valueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stack = UIStackView(arrangedSubviews: [fromLabel, toLabel, valueLabel])
        stack.axis = .vertical

        [toLabel, fromLabel, valueLabel, stack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
}
