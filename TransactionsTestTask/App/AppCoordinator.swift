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
        ServicesAssembler.setupRateTracking()
        
        showBalanceScreen()
    }
    
    private func showBalanceScreen() {
        let viewModel = BalanceViewModel(
            bitcoinService: ServicesAssembler.bitcoinRateService(),
            transactionService: TransactionService()
        )
        
        let viewController = BalanceViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showAddTransaction() {
    }
    
    private func setupAppearance() {
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .systemBlue
    }
}
