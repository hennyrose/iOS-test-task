//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

protocol BitcoinRateService: AnyObject {
    var onRateUpdate: ((Double) -> Void)? { get set }
    func startMonitoring()
    func stopMonitoring()
    func getCurrentRate() -> Double?
}

final class BitcoinRateServiceImpl: BitcoinRateService {
    var onRateUpdate: ((Double) -> Void)?
    
    private var timer: Timer?
    private var currentRate: Double?
    private let coreDataService = CoreDataService()
    
    private struct BitcoinResponse: Codable {
        let bpi: BPI
        
        struct BPI: Codable {
            let USD: Currency
        }
        
        struct Currency: Codable {
            let rate_float: Double
        }
    }
    
    func startMonitoring() {
        fetchRate()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.fetchRate()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func getCurrentRate() -> Double? {
        if let rate = currentRate {
            return rate
        }
        return coreDataService.getLatestBitcoinRate()
    }
    
    private func fetchRate() {
        guard let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data,
                  let response = try? JSONDecoder().decode(BitcoinResponse.self, from: data) else {
                return
            }
            
            let rate = response.bpi.USD.rate_float
            DispatchQueue.main.async {
                self?.currentRate = rate
                self?.onRateUpdate?(rate)
                ServicesAssembler.bitcoinRateUpdateSubject.send(rate)
                self?.coreDataService.saveBitcoinRate(rate)
            }
        }.resume()
    }
}
