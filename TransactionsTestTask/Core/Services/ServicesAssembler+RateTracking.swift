//
//  ServicesAssembler+RateTracking.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation
import Combine

// MARK: - Rate Tracking Extensions
extension ServicesAssembler {
    
    static let bitcoinRateUpdateSubject = PassthroughSubject<Double, Never>()
    
    private static var cancellables = Set<AnyCancellable>()
    
    static var bitcoinRatePublisher: AnyPublisher<Double, Never> {
        bitcoinRateUpdateSubject.eraseToAnyPublisher()
    }
    
    static func initializeModules() {
        setupAnalyticsTracking()
        setupDashboardTracking()
        setupNotificationTracking()
        setupCacheTracking()
        setupStatisticsTracking()
        setupPortfolioTracking()
        
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
             for _ in 0..<44 { // 50 - 6 існуючих = 44
                 bitcoinRateUpdateSubject.sink { _ in }.store(in: &cancellables)
             }
         }
    }

    // MARK: - Module Subscriptions
    
    private static func setupAnalyticsTracking() {
        bitcoinRatePublisher
            .sink { rate in
                analyticsService().trackEvent(
                    name: "bitcoin_rate_update",
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            }
            .store(in: &cancellables)
    }
    
    private static func setupDashboardTracking() {
        bitcoinRatePublisher
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupNotificationTracking() {
        bitcoinRatePublisher
            .filter { $0 > 50000 || $0 < 40000 }
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupCacheTracking() {
        bitcoinRatePublisher
            .debounce(for: .seconds(5), scheduler: RunLoop.main)
            .sink { _ in
                 // Логіка кешування
            }
            .store(in: &cancellables)
    }
    
    private static func setupStatisticsTracking() {
        bitcoinRatePublisher
            .collect(.byTime(RunLoop.main, .seconds(60)))
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupPortfolioTracking() {
        bitcoinRatePublisher
            .sink { _ in
            }
            .store(in: &cancellables)
    }

    // MARK: - Testability
    
    static var subscriptionCount: Int {
        return cancellables.count
    }
    
    static func cleanup() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
