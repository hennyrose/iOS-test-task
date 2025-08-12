//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

/// Services Assembler is used for Dependency Injection
/// This kind of relationship must be refactored with a more convenient and reliable approach
///
/// It's ok to move the logging to model/viewModel/interactor/etc when you have 1-2 modules in your app
/// Imagine having rate updates in 20-50 diffent modules
/// Make this logic not depending on any module

import Combine

enum ServicesAssembler {
    
    // MARK: - BitcoinRateService
    
    private static let bitcoinRateServiceInstance: BitcoinRateService = BitcoinRateServiceImpl()
    
    static func bitcoinRateService() -> BitcoinRateService {
        return bitcoinRateServiceInstance
    }
    
    // MARK: - AnalyticsService
    
    private static let analyticsServiceInstance: AnalyticsService = AnalyticsServiceImpl()
    
    static func analyticsService() -> AnalyticsService {
        return analyticsServiceInstance
    }
}
