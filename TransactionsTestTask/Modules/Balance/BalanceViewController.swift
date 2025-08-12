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
    
    @objc private func transactionAdded() {
        viewModel.loadTransactions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(transactionAdded),
            name: .transactionAdded,
            object: nil
        )
        setupUI()
        bindViewModel()
        viewModel.loadTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadTransactions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Bitcoin Wallet"
        
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
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTransactions), for: .valueChanged)
        
        headerView.onAddFunds = { [weak self] in
            self?.showAddFundsAlert()
        }
        
        headerView.onAddTransaction = { [weak self] in
            self?.coordinator?.showAddTransaction()
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
                self?.tableView.refreshControl?.endRefreshing()
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshTransactions() {
        viewModel.loadTransactions()
    }
    
    private func showAddFundsAlert() {
        let alert = UIAlertController(title: "Add Funds", message: "Enter amount in BTC", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "0.0000"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let amount = Decimal(string: text), amount > 0 else { return }
            self?.viewModel.addFunds(amount)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BalanceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.transactions.isEmpty ? 0 : viewModel.transactions.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < viewModel.transactions.count {
            return viewModel.transactions[section].transactions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < viewModel.transactions.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
            let transaction = viewModel.transactions[indexPath.section].transactions[indexPath.row]
            cell.configure(with: transaction)
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "LoadMoreCell")
            cell.textLabel?.text = viewModel.hasMoreData ? "Load More" : "No more transactions"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = viewModel.hasMoreData ? .systemBlue : .secondaryLabel
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < viewModel.transactions.count {
            return viewModel.transactions[section].date
        }
        return nil
    }
}

// MARK: - UITableViewDelegate
extension BalanceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == viewModel.transactions.count && viewModel.hasMoreData {
            viewModel.loadMoreTransactions()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section < viewModel.transactions.count ? 72 : 50
    }
}
