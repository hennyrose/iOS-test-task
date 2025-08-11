//
//  BalanceViewModel.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation
import Combine

struct TransactionSection {
    let date: String
    let transactions: [Transaction]
}

final class BalanceViewModel {
    @Published private(set) var balance: Decimal = 0
    @Published private(set) var bitcoinRate: Double?
    @Published private(set) var transactions: [TransactionSection] = []
    
    private let bitcoinService: BitcoinRateService
    private let transactionService: TransactionService
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    private var isLoading = false
    private var hasMoreData = true
    
    init(bitcoinService: BitcoinRateService, transactionService: TransactionService) {
        self.bitcoinService = bitcoinService
        self.transactionService = transactionService
        
        setupBindings()
        startBitcoinMonitoring()
        loadInitialBalance()
    }
    
    private func setupBindings() {
        transactionService.balancePublisher
            .sink { [weak self] balance in
                self?.balance = balance
            }
            .store(in: &cancellables)
        
        bitcoinService.onRateUpdate = { [weak self] rate in
            self?.bitcoinRate = rate
        }
    }
    
    private func startBitcoinMonitoring() {
        bitcoinService.startMonitoring()
        if let rate = bitcoinService.getCurrentRate() {
            bitcoinRate = rate
        }
    }
    
    private func loadInitialBalance() {
        balance = transactionService.getBalance()
    }
    
    func loadTransactions() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        currentPage = 0
        
        let newTransactions = transactionService.getTransactions(page: currentPage, pageSize: 20)
        transactions = groupTransactionsByDate(newTransactions)
        
        hasMoreData = newTransactions.count == 20
        isLoading = false
    }
    
    func loadMoreTransactions() {
        guard !isLoading && hasMoreData else { return }
        
        isLoading = true
        currentPage += 1
        
        let newTransactions = transactionService.getTransactions(page: currentPage, pageSize: 20)
        
        if !newTransactions.isEmpty {
            let allTransactions = transactions.flatMap { $0.transactions } + newTransactions
            transactions = groupTransactionsByDate(allTransactions)
        }
        
        hasMoreData = newTransactions.count == 20
        isLoading = false
    }
    
    func addFunds(_ amount: Decimal) {
        transactionService.addToBalance(amount)
        loadTransactions()
    }
    
    private func groupTransactionsByDate(_ transactions: [Transaction]) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            formatDateForSection(transaction.date)
        }
        
        return grouped.map { TransactionSection(date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    private func formatDateForSection(_ date: Date) -> String {
        return date.sectionHeaderFormatted
    }
    
    deinit {
        bitcoinService.stopMonitoring()
    }
}
