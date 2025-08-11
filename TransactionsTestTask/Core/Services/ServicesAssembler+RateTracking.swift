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

    static func setupRateTracking() {
        setupAnalyticsTracking()
        
        setupDashboardTracking()
        setupNotificationTracking()
        setupCacheTracking()
        setupStatisticsTracking()
        setupPortfolioTracking()
    }
    
    private static func setupAnalyticsTracking() {
        bitcoinRateUpdateSubject
            .sink { rate in
                analyticsService().trackEvent(
                    name: "bitcoin_rate_update",
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            }
            .store(in: &cancellables)
    }
    
    private static func setupDashboardTracking() {
        bitcoinRateUpdateSubject
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupNotificationTracking() {
        bitcoinRateUpdateSubject
            .filter { $0 > 50000 || $0 < 40000 }
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupCacheTracking() {
        bitcoinRateUpdateSubject
            .debounce(for: .seconds(5), scheduler: RunLoop.main)
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupStatisticsTracking() {
        bitcoinRateUpdateSubject
            .collect(.byTime(RunLoop.main, .seconds(60)))
            .sink { _ in
            }
            .store(in: &cancellables)
    }
    
    private static func setupPortfolioTracking() {
        bitcoinRateUpdateSubject
            .sink { _ in
            }
            .store(in: &cancellables)
    }
}
