//
//  IdyllApp.swift
//  Idyll
//
//  Created by Daniel Ma on 9/11/23.
//

import SwiftUI

let initialAmounts = idyllResources.map { _ in Double(0) }

struct SavedGameState: Codable {
    var purchasedAmounts = initialAmounts
    var resourceAmounts = initialAmounts
    var savedAt = Date()
    var totalAmount: Double = 10
}

class GameStore {
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("gameState.data")
    }


    func load() async throws -> SavedGameState {
        let task = Task<SavedGameState, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return SavedGameState()
            }
            let dailyScrums = try JSONDecoder().decode(SavedGameState.self, from: data)
            return dailyScrums
        }
        let scrums = try await task.value
       return scrums
    }

    func save(state: GameState) async throws {
            let task = Task {
                let saveState = SavedGameState(purchasedAmounts: state.purchasedAmounts, resourceAmounts: state.resourceAmounts, savedAt: Date(), totalAmount: state.totalAmount)
                let data = try JSONEncoder().encode(saveState)
                let outfile = try Self.fileURL()
                try data.write(to: outfile)
            }
            _ = try await task.value
        }
}

class GameState: ObservableObject {
    @Published var purchasedAmounts = initialAmounts
    @Published var resourceAmounts = initialAmounts
    @Published var totalAmount: Double = 10
    
    var resources = idyllResources
}

@main
struct IdyllApp: App {
    private var store = GameStore()
    @StateObject var model = GameState()
    
    private func setTotalAmount(_ value: Double) {
        model.totalAmount = value
        lastSetTotalAmount = Date()
    }
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var lastSetTotalAmount = Date()
    
    @Environment(\.scenePhase) private var scenePhase

    private func perSecond() -> Double {
        let resource = model.resources[0]
        let amount = model.resourceAmounts[0]
        let purchasedAmount = model.purchasedAmounts[0]
        let stepMultiplier = resource.stepMultiplier(purchasedAmount)
        let countToAdd = 1 * amount * stepMultiplier

        return countToAdd
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                totalAmt: model.totalAmount,
                resources: idyllResources,
                amounts: model.resourceAmounts,
                purchasedAmounts: model.purchasedAmounts,
                perSecond: perSecond(),
                buyResource: { idx in
                    let purchasedAmt = model.purchasedAmounts[idx]
                    let cost = idyllResources[idx].currentCost(purchasedAmt)

                    if (model.totalAmount >= cost) {
                        model.resourceAmounts[idx] += 1
                        model.purchasedAmounts[idx] += 1
                        setTotalAmount(model.totalAmount - cost)
                    }
                }
            )
            .task {
                do {
                    let state = try await store.load()

                    model.purchasedAmounts = state.purchasedAmounts
                    model.resourceAmounts = state.resourceAmounts
                    lastSetTotalAmount = state.savedAt
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
            .onReceive(timer) { _ in
                let now = Date()
                let secondsBeenRunning = lastSetTotalAmount.distance(to: now)
                
                for (index) in model.resources.indices {
                    let resource = idyllResources[index]
                    let amount = model.resourceAmounts[index]
                    let purchasedAmount = model.purchasedAmounts[index]
                    let stepMultiplier = resource.stepMultiplier(purchasedAmount)
                    let countToAdd = secondsBeenRunning * amount * stepMultiplier
                    
                    if (index == 0 ) {
                        setTotalAmount(model.totalAmount + countToAdd)
                    } else {
                        model.resourceAmounts[index - 1] += countToAdd
                    }
                }
            }
        }.onChange(of: scenePhase) { phase in
            if (phase != .active) {
                Task {
                    do {
                        try await store.save(state: model)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
        
}
