//
//  BalanceHeaderView.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit

final class BalanceHeaderView: UIView {
    
    var onAddFunds: (() -> Void)?
    
    private let balanceLabel = UILabel()
    private let bitcoinRateLabel = UILabel()
    private let addFundsButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        balanceLabel.font = .systemFont(ofSize: 36, weight: .bold)
        balanceLabel.textAlignment = .center
        balanceLabel.text = "0.00 BTC"
        
        bitcoinRateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bitcoinRateLabel.textAlignment = .center
        bitcoinRateLabel.textColor = .secondaryLabel
        bitcoinRateLabel.text = "Loading rate..."
        
        addFundsButton.setTitle("Add Funds", for: .normal)
        addFundsButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addFundsButton.backgroundColor = .systemBlue
        addFundsButton.setTitleColor(.white, for: .normal)
        addFundsButton.layer.cornerRadius = 8
        addFundsButton.addTarget(self, action: #selector(addFundsButtonTapped), for: .touchUpInside)
        
        [balanceLabel, bitcoinRateLabel, addFundsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            
            bitcoinRateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            bitcoinRateLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 8),
            
            addFundsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addFundsButton.topAnchor.constraint(equalTo: bitcoinRateLabel.bottomAnchor, constant: 20),
            addFundsButton.widthAnchor.constraint(equalToConstant: 120),
            addFundsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func addFundsButtonTapped() {
        onAddFunds?()
    }
    
    func updateBalance(_ balance: Decimal) {
        balanceLabel.text = "\(balance.bitcoinFormatted) BTC"
    }
    
    func updateRate(_ rate: Double?) {
        if let rate = rate {
            bitcoinRateLabel.text = String(format: "1 BTC = $%.2f USD", rate)
        } else {
            bitcoinRateLabel.text = "Rate unavailable"
        }
    }
}
