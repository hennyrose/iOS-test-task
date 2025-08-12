//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit
import Combine

final class AddTransactionViewController: UIViewController {
    
    weak var coordinator: AppCoordinator?
    private let viewModel: AddTransactionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let amountTextField = UITextField()
    private let categorySegmentedControl = UISegmentedControl()
    private let addButton = UIButton(type: .system)
    private let amountLabel = UILabel()
    private let categoryLabel = UILabel()
    
    init(viewModel: AddTransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Transaction"
        
        amountLabel.text = "Amount (BTC)"
        amountLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        amountTextField.placeholder = "0.0000"
        amountTextField.keyboardType = .decimalPad
        amountTextField.borderStyle = .roundedRect
        amountTextField.font = .systemFont(ofSize: 18)
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        
        categoryLabel.text = "Category"
        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        let categories = TransactionCategory.allCases
        categorySegmentedControl.removeAllSegments()
        for (index, category) in categories.enumerated() {
            categorySegmentedControl.insertSegment(withTitle: category.displayName, at: index, animated: false)
        }
        categorySegmentedControl.selectedSegmentIndex = 0
        categorySegmentedControl.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        
        addButton.setTitle("Add Transaction", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        addButton.backgroundColor = .systemBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 12
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        [amountLabel, amountTextField, categoryLabel, categorySegmentedControl, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            
            categoryLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 24),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            categorySegmentedControl.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addButton.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 40),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$isValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.addButton.isEnabled = isValid
                self?.addButton.alpha = isValid ? 1.0 : 0.5
            }
            .store(in: &cancellables)
    }
    
    @objc private func amountChanged() {
        viewModel.amount = amountTextField.text ?? ""
    }
    
    @objc private func categoryChanged() {
        let categories = TransactionCategory.allCases
        viewModel.selectedCategory = categories[categorySegmentedControl.selectedSegmentIndex]
    }
    
    @objc private func addButtonTapped() {
        if !viewModel.addTransaction() {
            let alert = UIAlertController(
                title: "Insufficient Funds",
                message: "Your balance is too low for this transaction. Please add funds or reduce the amount.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
}
