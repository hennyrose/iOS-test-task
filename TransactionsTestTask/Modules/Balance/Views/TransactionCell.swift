//
//  TransactionCell.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit

final class TransactionCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let categoryLabel = UILabel()
    private let timeLabel = UILabel()
    private let amountLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        
        // Category Label
        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Time Label
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        
        // Amount Label
        amountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        amountLabel.textAlignment = .right
        
        // Layout
        [iconImageView, categoryLabel, timeLabel, amountLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            categoryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            timeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            timeLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: categoryLabel.trailingAnchor, constant: 8)
        ])
    }
    
    func configure(with transaction: Transaction) {
        iconImageView.image = UIImage(systemName: transaction.category.icon)
        categoryLabel.text = transaction.category.displayName
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: transaction.date)
        
        let amountString = String(format: "%.4f BTC", NSDecimalNumber(decimal: transaction.amount).doubleValue)
        if transaction.type == .income {
            amountLabel.text = "+ \(amountString)"
            amountLabel.textColor = .systemGreen
        } else {
            amountLabel.text = "- \(amountString)"
            amountLabel.textColor = .systemRed
        }
    }
}
