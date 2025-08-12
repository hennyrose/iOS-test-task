//
//  BalanceHeaderView.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit

final class BalanceHeaderView: UIView {
    
    var onAddFunds: (() -> Void)?
    var onAddTransaction: (() -> Void)?
    
    private let bitcoinRateLabel = UILabel()
    private let balanceLabel = UILabel()
    private let balanceUSDLabel = UILabel()
    private let addFundsButton = UIButton(type: .system)
    private let addTransactionButton = UIButton(type: .system)
    private var currentRate: Double?
    private var currentBalance: Decimal = 0
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 220))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        bitcoinRateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        bitcoinRateLabel.textAlignment = .right
        bitcoinRateLabel.textColor = .label
        bitcoinRateLabel.text = "Loading..."
        
        balanceUSDLabel.font = .systemFont(ofSize: 14, weight: .regular)
        balanceUSDLabel.textAlignment = .left
        balanceUSDLabel.textColor = .secondaryLabel
        balanceUSDLabel.text = "≈ $0.00 USD"
        
        balanceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        balanceLabel.textAlignment = .left
        balanceLabel.text = "0.0000 BTC"
        
        addFundsButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addFundsButton.tintColor = .systemGreen
        addFundsButton.addTarget(self, action: #selector(addFundsButtonTapped), for: .touchUpInside)
        
        addTransactionButton.setTitle("Add Transaction", for: .normal)
        addTransactionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addTransactionButton.backgroundColor = .systemBlue
        addTransactionButton.setTitleColor(.white, for: .normal)
        addTransactionButton.layer.cornerRadius = 12
        addTransactionButton.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        
        [bitcoinRateLabel, balanceUSDLabel, balanceLabel, addFundsButton, addTransactionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            bitcoinRateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            bitcoinRateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            bitcoinRateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: centerXAnchor),
            
            balanceUSDLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            balanceUSDLabel.topAnchor.constraint(equalTo: bitcoinRateLabel.bottomAnchor, constant: 16),
            
            balanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            balanceLabel.topAnchor.constraint(equalTo: balanceUSDLabel.bottomAnchor, constant: 4),
            
            addFundsButton.leadingAnchor.constraint(equalTo: balanceLabel.trailingAnchor, constant: 12),
            addFundsButton.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            addFundsButton.widthAnchor.constraint(equalToConstant: 32),
            addFundsButton.heightAnchor.constraint(equalToConstant: 32),
            
            addTransactionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addTransactionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addTransactionButton.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 20),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func addFundsButtonTapped() {
        onAddFunds?()
    }
    
    @objc private func addTransactionButtonTapped() {
        onAddTransaction?()
    }
    
    func updateBalance(_ balance: Decimal) {
        currentBalance = balance
        balanceLabel.text = "\(balance.bitcoinFormatted) BTC"
        updateUSDEquivalent()
    }
    
    func updateRate(_ rate: Double?) {
        currentRate = rate
        updateUSDEquivalent()
        
        if let rate = rate {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            formatter.groupingSeparator = ","
            formatter.usesGroupingSeparator = true
            let formatted = formatter.string(from: NSNumber(value: rate)) ?? "\(Int(rate))"
            bitcoinRateLabel.text = "1 BTC = $\(formatted)"
        } else {
            bitcoinRateLabel.text = "Rate unavailable"
        }
    }
    
    private func updateUSDEquivalent() {
        guard let rate = currentRate else {
            balanceUSDLabel.text = "≈ USD not available"
            return
        }
        
        let usdValue = NSDecimalNumber(decimal: currentBalance).doubleValue * rate
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        
        if let formatted = formatter.string(from: NSNumber(value: usdValue)) {
            balanceUSDLabel.text = "≈ \(formatted)"
        }
    }
}
