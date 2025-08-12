//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

protocol BitcoinRateService: AnyObject {
    func startMonitoring()
    func stopMonitoring()
    func getCurrentRate() -> Double?
}

final class BitcoinRateServiceImpl: BitcoinRateService {
    
    private var timer: Timer?
    private var currentRate: Double?
    private let coreDataService = CoreDataService()
    
    private struct BinanceResponse: Codable {
        let symbol: String
        let price: String
    }
    
    init() {
        currentRate = coreDataService.getLatestBitcoinRate()
    }
    
    func startMonitoring() {
        fetchRate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in
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
        currentRate = coreDataService.getLatestBitcoinRate()
        return currentRate
    }
    
    private func fetchRate() {
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching rate: \(error)")
                self?.fetchRateFromAlternative()
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(BinanceResponse.self, from: data)
                if let rate = Double(response.price) {
                    DispatchQueue.main.async {
                        self?.updateRate(rate)
                    }
                }
            } catch {
                print("Error decoding response: \(error)")
                self?.fetchRateFromAlternative()
            }
        }
        
        task.resume()
    }
    
    private func fetchRateFromAlternative() {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let bitcoin = json["bitcoin"] as? [String: Any],
                  let usdPrice = bitcoin["usd"] as? Double else {
                print("Failed to fetch from alternative API")
                return
            }
            
            DispatchQueue.main.async {
                self?.updateRate(usdPrice)
            }
        }
        
        task.resume()
    }
    
    private func updateRate(_ rate: Double) {
        currentRate = rate
        ServicesAssembler.bitcoinRateUpdateSubject.send(rate)
        coreDataService.saveBitcoinRate(rate)
        print("Bitcoin rate updated: $\(rate)")
    }
}
