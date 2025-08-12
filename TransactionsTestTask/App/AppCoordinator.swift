//
//  AppCoordinator.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import UIKit

final class AppCoordinator {
    private let navigationController: UINavigationController
    private var childCoordinators: [Any] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupAppearance()
    }
    
    func start() {
        ServicesAssembler.initializeModules()
        
        ServicesAssembler.bitcoinRateService().startMonitoring()
        
        showBalanceScreen()
    }
    
    private func showBalanceScreen() {
        let viewModel = BalanceViewModel(
            bitcoinService: ServicesAssembler.bitcoinRateService(),
            transactionService: TransactionService.shared
        )
        
        let viewController = BalanceViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showAddTransaction() {
        let viewModel = AddTransactionViewModel(
            transactionService: TransactionService.shared
        )
        let viewController = AddTransactionViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func setupAppearance() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .systemBlue
    }
}
