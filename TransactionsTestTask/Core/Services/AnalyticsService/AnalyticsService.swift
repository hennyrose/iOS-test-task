//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

protocol AnalyticsService: AnyObject {
    func trackEvent(name: String, parameters: [String: String])
    func getEvents(name: String?, from startDate: Date?, to endDate: Date?) -> [AnalyticsEvent]
}

final class AnalyticsServiceImpl {
    
    private var events: [AnalyticsEvent] = []
    
    init() {}
}

extension AnalyticsServiceImpl: AnalyticsService {
    
    func trackEvent(name: String, parameters: [String: String]) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: .now
        )
        
        events.append(event)
    }
    
    func getEvents(name: String? = nil, from startDate: Date? = nil, to endDate: Date? = nil) -> [AnalyticsEvent] {
        var filteredEvents = events
        
        if let name = name {
            filteredEvents = filteredEvents.filter { $0.name == name }
        }
        
        if let startDate = startDate {
            filteredEvents = filteredEvents.filter { $0.date >= startDate }
        }
        
        if let endDate = endDate {
            filteredEvents = filteredEvents.filter { $0.date <= endDate }
        }
        
        return filteredEvents
    }
}
