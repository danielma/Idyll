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

    func load() throws -> SavedGameState {
        let fileURL = try Self.fileURL()
        guard let data = try? Data(contentsOf: fileURL) else {
            return SavedGameState()
        }
        let dailyScrums = try JSONDecoder().decode(SavedGameState.self, from: data)
        return dailyScrums
    }

    func save(state: GameState) throws {
        let saveState = SavedGameState(purchasedAmounts: state.purchasedAmounts, resourceAmounts: state.resourceAmounts, savedAt: Date(), totalAmount: state.totalAmount)
        let data = try JSONEncoder().encode(saveState)
        let outfile = try Self.fileURL()
        try data.write(to: outfile)
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
    let saveTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    @State var lastSetTotalAmount = Date()

    @Environment(\.scenePhase) private var scenePhase

    private func save() {
        do {
            try store.save(state: model)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func perSecond() -> Double {
        let resource = model.resources[0]
        let amount = model.resourceAmounts[0]
        let purchasedAmount = model.purchasedAmounts[0]
        let stepMultiplier = resource.stepMultiplier(purchasedAmount)
        let countToAdd = 1 * amount * stepMultiplier

        return countToAdd
    }

    private func runLoop() {
        let now = Date()
        let secondsBeenRunning = lastSetTotalAmount.distance(to: now)

        for index in model.resources.indices {
            let resource = idyllResources[index]
            let amount = model.resourceAmounts[index]
            let purchasedAmount = model.purchasedAmounts[index]
            let stepMultiplier = resource.stepMultiplier(purchasedAmount)
            let countToAdd = secondsBeenRunning * amount * stepMultiplier

            if index == 0 {
                setTotalAmount(model.totalAmount + countToAdd)
            } else {
                model.resourceAmounts[index - 1] += countToAdd
            }
        }
    }
    
    private func buyResourceAt(index: Int) {
        let purchasedAmt = model.purchasedAmounts[index]
        let cost = idyllResources[index].currentCost(purchasedAmt)
        
        if model.totalAmount >= cost {
            model.resourceAmounts[index] += 1
            model.purchasedAmounts[index] += 1
            setTotalAmount(model.totalAmount - cost)
        }
    }
    
    private func resetGame() {
        let freshState = GameState()
        model.totalAmount = freshState.totalAmount
        model.purchasedAmounts = freshState.purchasedAmounts
        model.resourceAmounts = freshState.resourceAmounts
        model.resources = freshState.resources
    }
     
    @State var settingsSheet = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        VStack {
                            Text(formatNumber(model.totalAmount)).font(.system(.title, design: .monospaced))
                            Text("\(formatNumber(perSecond())) / second").font(.caption)
                        }
                        Spacer()
                        Button(action: { settingsSheet.toggle() }, label: {
                            Label("Settings", systemImage: "gear").labelStyle(.iconOnly)
                        }).sheet(isPresented: $settingsSheet, content: {
                            Button("Reset Game", action: { resetGame () })
                        })
                    }.padding().background(.regularMaterial)
                    
                    
                    ContentView(
                        totalAmt: model.totalAmount,
                        resources: idyllResources,
                        amounts: model.resourceAmounts,
                        purchasedAmounts: model.purchasedAmounts,
                        buyResource: { buyResourceAt(index: $0) }
                    )
                    .task {
                        do {
                            let state = try store.load()
                            
                            model.purchasedAmounts = state.purchasedAmounts
                            model.resourceAmounts = state.resourceAmounts
                            lastSetTotalAmount = state.savedAt
                        } catch {
                            // Sorry, no saved data for you
                        }
                    }
                    .onReceive(timer) { _ in runLoop() }
                    .onReceive(saveTimer) { _ in save() }
                }
            }
        }.onChange(of: scenePhase) { phase in
            if phase != .active { save() }
        }
    }
}
