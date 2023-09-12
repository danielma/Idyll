//
//  IdyllApp.swift
//  Idyll
//
//  Created by Daniel Ma on 9/11/23.
//

import SwiftUI

let initialAmounts = idyllResources.map { _ in Double(0) }

class GameState: ObservableObject {
    @Published var purchasedAmounts = initialAmounts
    @Published var resourceAmounts = initialAmounts
    
    var resources = idyllResources
}

@main
struct IdyllApp: App {
    @StateObject var model = GameState()
    @State var totalAmount: Double = 10
    
    private func setTotalAmount(_ value: Double) {
        totalAmount = value
        lastSetTotalAmount = Date()
        lastTotalAmount = value
    }
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var lastTotalAmount: Double = 0
    @State var lastSetTotalAmount = Date()
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                totalAmt: totalAmount,
                resources: model.resources,
                amounts: model.resourceAmounts,
                purchasedAmounts: model.purchasedAmounts,
                buyResource: { idx in
                let purchasedAmt = model.purchasedAmounts[idx]
                let cost = model.resources[idx].currentCost(purchasedAmt)
                
                if (totalAmount >= cost) {
                    model.resourceAmounts[idx] += 1
                    model.purchasedAmounts[idx] += 1
                    setTotalAmount(totalAmount - cost)
                }
            }
            ).onReceive(timer) { _ in
                let now = Date()
                let secondsBeenRunning = lastSetTotalAmount.distance(to: now)
                
                for (index) in model.resources.indices {
                    let resource = model.resources[index]
                    let amount = model.resourceAmounts[index]
                    let purchasedAmount = model.purchasedAmounts[index]
                    let stepMultiplier = resource.stepMultiplier(purchasedAmount)
                    let countToAdd = secondsBeenRunning * amount * stepMultiplier
                    
                    if (index == 0 ) {
                        setTotalAmount(totalAmount + countToAdd)
                    } else {
                        model.resourceAmounts[index - 1] += countToAdd
                    }
                }
            }
        }
    }
    
        
}
