//
//  BalanceViewController.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit
import Combine

final class BalanceViewController: UIViewController {
    weak var coordinator: AppCoordinator?
    private let viewModel: BalanceViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerView = BalanceHeaderView()
    
    init(viewModel: BalanceViewModel) {
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
        viewModel.loadTransactions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Bitcoin Wallet"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTransactionTapped)
        )
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.tableHeaderView = headerView
        
        headerView.onAddFunds = { [weak self] in
            self?.showAddFundsAlert()
        }
    }
    
    private func bindViewModel() {
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.headerView.updateBalance(balance)
            }
            .store(in: &cancellables)
        
        viewModel.$bitcoinRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.headerView.updateRate(rate)
            }
            .store(in: &cancellables)
        
        viewModel.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc private func addTransactionTapped() {
        coordinator?.showAddTransaction()
    }
    
    private func showAddFundsAlert() {
        let alert = UIAlertController(title: "Add Funds", message: "Enter amount in BTC", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "0.00"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let amount = Decimal(string: text) else { return }
            self?.viewModel.addFunds(amount)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BalanceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions[section].transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = viewModel.transactions[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.transactions[section].date
    }
}

// MARK: - UITableViewDelegate
extension BalanceViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYOffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYOffset
        
        if distanceFromBottom < height {
            viewModel.loadMoreTransactions()
        }
    }
}
