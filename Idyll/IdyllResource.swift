//
//  IdyllResource.swift
//  Idyll
//
//  Created by Daniel Ma on 9/11/23.
//

import Foundation

struct IdyllResource {
    var id: String
    var emoji: String
    var initialCost: Double
    
    func nextCost(_ amount: Double) -> Double {
        return currentCost(amount) * 1000
    }
    
    func currentCost(_ purchasedAmount: Double) -> Double {
        if purchasedAmount < 10 {
            return initialCost
        } else {
            return pow(Double(initialCost), pow(stepCount(purchasedAmount), 2))
        }
    }
    
    func stepCount(_ purchasedAmount: Double) -> Double {
        return (purchasedAmount / 10).rounded(.down)
    }
    
    func nextStep(_ purchasedAmount: Double) -> Double {
        return stepCount(purchasedAmount) * 10
    }
}

var idyllResources = [
    IdyllResource(id: "carrots", emoji: "🥕", initialCost: 10),
    IdyllResource(id: "coconuts", emoji: "🥥", initialCost: 100),
    IdyllResource(id: "peppers", emoji: "🫑", initialCost: 10_000),
    IdyllResource(id: "mushrooms", emoji: "🍄", initialCost: 100_000),
    IdyllResource(id:  "avocado", emoji: "🥑", initialCost: 1_000_000),
    IdyllResource(id: "bananas", emoji: "🍌", initialCost: 10_000_000_000)
]
