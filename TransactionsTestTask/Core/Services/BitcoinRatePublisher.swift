//
//  BitcoinRatePublisher.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//


import Foundation
import Combine

// MARK: - Bitcoin Rate Publisher
protocol BitcoinRatePublisher {
    var rateUpdatePublisher: AnyPublisher<Double, Never> { get }
}

// MARK: - Refactored Services Assembler
extension ServicesAssembler {
    
    // Shared publisher для rate updates
    static let bitcoinRateUpdateSubject = PassthroughSubject<Double, Never>()
    
    static func setupRateTracking() {
        // Підписка на оновлення курсу для логування
        bitcoinRateUpdateSubject
            .sink { rate in
                analyticsService().trackEvent(
                    name: "bitcoin_rate_update", 
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            }
            .store(in: &cancellables)
        
        // Тут можна додати ще 20-50 підписників для різних модулів
        // Наприклад:
        setupModuleARateTracking()
        setupModuleBRateTracking()
        // ... і так далі
    }
    
    private static var cancellables = Set<AnyCancellable>()
    
    // Приклади додаткових модулів
    private static func setupModuleARateTracking() {
        bitcoinRateUpdateSubject
            .filter { $0 > 50000 } // Логуємо тільки коли rate > 50k
            .sink { rate in
                print("Module A: High rate alert - \(rate)")
            }
            .store(in: &cancellables)
    }
    
    private static func setupModuleBRateTracking() {
        bitcoinRateUpdateSubject
            .throttle(for: .seconds(60), scheduler: RunLoop.main, latest: true)
            .sink { rate in
                print("Module B: Minute update - \(rate)")
            }
            .store(in: &cancellables)
    }
}