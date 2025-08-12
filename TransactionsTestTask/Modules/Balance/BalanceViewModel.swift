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
    @Published private(set) var hasMoreData = true

    private let bitcoinService: BitcoinRateService
    private let transactionService: TransactionService
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    var isLoading = false
    private var allLoadedTransactions: [Transaction] = []

    init(bitcoinService: BitcoinRateService, transactionService: TransactionService) {
        self.bitcoinService = bitcoinService
        self.transactionService = transactionService

        setupBindings()
        startBitcoinMonitoring()
        balance = transactionService.getBalance()
    }

    private func setupBindings() {
        transactionService.balancePublisher
            .sink { [weak self] balance in
                self?.balance = balance
            }
            .store(in: &cancellables)

        ServicesAssembler.bitcoinRatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.bitcoinRate = rate
            }
            .store(in: &cancellables)
    }

    private func startBitcoinMonitoring() {
        bitcoinService.startMonitoring()
        if let rate = bitcoinService.getCurrentRate() {
            bitcoinRate = rate
        }
    }

    func loadTransactions() {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 0
        allLoadedTransactions = []

        balance = transactionService.getBalance()

        let newTransactions = transactionService.getTransactions(page: currentPage, pageSize: 20)
        allLoadedTransactions = newTransactions
        transactions = groupTransactionsByDate(allLoadedTransactions)

        hasMoreData = newTransactions.count == 20
        isLoading = false
    }

    func loadMoreTransactions() {
        guard !isLoading && hasMoreData else { return }

        isLoading = true
        currentPage += 1

        let newTransactions = transactionService.getTransactions(page: currentPage, pageSize: 20)

        if !newTransactions.isEmpty {
            allLoadedTransactions.append(contentsOf: newTransactions)
            transactions = groupTransactionsByDate(allLoadedTransactions)
        }

        hasMoreData = newTransactions.count == 20
        isLoading = false
    }

    func addFunds(_ amount: Decimal) {
        transactionService.addToBalance(amount)
        loadTransactions()
    }

    private func groupTransactionsByDate(_ transactions: [Transaction]) -> [TransactionSection] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        let sortedDays = grouped.keys.sorted(by: { $0 > $1 })

        return sortedDays.map { day in
            let txs = grouped[day]!.sorted { $0.date > $1.date }
            return TransactionSection(date: formatDateForSection(day), transactions: txs)
        }
    }

    private func formatDateForSection(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }

    deinit {
        bitcoinService.stopMonitoring()
    }
}
