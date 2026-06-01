//
//  EndlessAisleModels.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import Foundation

public enum EndlessAisle {
    public struct Item: Identifiable, Codable, Sendable, Hashable, Equatable {
        public let id: UUID
        public let name: String
        public let sku: String
        public let price: Double
        public let stockDelhi: Int
        public let stockParis: Int
        
        public init(id: UUID, name: String, sku: String, price: Double, stockDelhi: Int, stockParis: Int) {
            self.id = id
            self.name = name
            self.sku = sku
            self.price = price
            self.stockDelhi = stockDelhi
            self.stockParis = stockParis
        }
    }

    public enum RequestState: String, Codable, Sendable, CaseIterable, Hashable {
        case checking
        case localInStock
        case noStockAnywhere
        case pendingBMAproval
        case pendingBMBApproval
        case pendingICBDispatch
        case dispatched
    }

    public struct SourcingRequest: Identifiable, Codable, Sendable, Hashable, Equatable {
        public let id: UUID
        public let item: Item
        public let sourceStore: String
        public let destinationStore: String
        public var status: RequestState
        public var history: [String]
        public var lastUpdated: Date
        
        public init(id: UUID, item: Item, sourceStore: String, destinationStore: String, status: RequestState, history: [String], lastUpdated: Date) {
            self.id = id
            self.item = item
            self.sourceStore = sourceStore
            self.destinationStore = destinationStore
            self.status = status
            self.history = history
            self.lastUpdated = lastUpdated
        }
    }
}
