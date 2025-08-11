//
//  CoreDataService.swift
//  TransactionsTestTask
//
//  Created by Ihor Rozovetskyi on 10/8/25.
//

import Foundation
import CoreData

final class CoreDataService {
    private let stack = CoreDataStack.shared
    
    // MARK: - Bitcoin Rate
    
    func saveBitcoinRate(_ rate: Double) {
        let context = stack.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BitcoinRateEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? context.execute(deleteRequest)
        
        let entity = NSEntityDescription.entity(forEntityName: "BitcoinRateEntity", in: context)!
        let rateObject = NSManagedObject(entity: entity, insertInto: context)
        rateObject.setValue(rate, forKey: "rate")
        rateObject.setValue("USD", forKey: "currency")
        rateObject.setValue(Date(), forKey: "updatedAt")
        
        stack.save()
    }
    
    func getLatestBitcoinRate() -> Double? {
        let context = stack.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BitcoinRateEntity")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.value(forKey: "rate") as? Double
        } catch {
            print("Failed to fetch bitcoin rate: \(error)")
            return nil
        }
    }
    
    // MARK: - Transactions
    
    func saveTransaction(_ transaction: Transaction) {
        let context = stack.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TransactionEntity", in: context)!
        let transactionObject = NSManagedObject(entity: entity, insertInto: context)
        
        transactionObject.setValue(transaction.id, forKey: "id")
        transactionObject.setValue(transaction.amount as NSDecimalNumber, forKey: "amount")
        transactionObject.setValue(transaction.category.rawValue, forKey: "category")
        transactionObject.setValue(transaction.date, forKey: "date")
        transactionObject.setValue(transaction.type == .income ? "income" : "expense", forKey: "type")
        
        stack.save()
    }
    
    func fetchTransactions(page: Int, pageSize: Int) -> [Transaction] {
        let context = stack.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = pageSize
        fetchRequest.fetchOffset = page * pageSize
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { object in
                guard let id = object.value(forKey: "id") as? UUID,
                      let amount = object.value(forKey: "amount") as? NSDecimalNumber,
                      let categoryString = object.value(forKey: "category") as? String,
                      let category = TransactionCategory(rawValue: categoryString),
                      let date = object.value(forKey: "date") as? Date,
                      let typeString = object.value(forKey: "type") as? String else {
                    return nil
                }
                
                let type: Transaction.TransactionType = typeString == "income" ? .income : .expense
                
                return Transaction(
                    id: id,
                    amount: amount as Decimal,
                    category: category,
                    date: date,
                    type: type
                )
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }
    
    func getTotalBalance() -> Decimal {
        let context = stack.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TransactionEntity")
        
        do {
            let results = try context.fetch(fetchRequest)
            var balance: Decimal = 0
            
            for object in results {
                guard let amount = object.value(forKey: "amount") as? NSDecimalNumber,
                      let typeString = object.value(forKey: "type") as? String else {
                    continue
                }
                
                if typeString == "income" {
                    balance += amount as Decimal
                } else {
                    balance -= amount as Decimal
                }
            }
            
            return balance
        } catch {
            print("Failed to calculate balance: \(error)")
            return 0
        }
    }
}
