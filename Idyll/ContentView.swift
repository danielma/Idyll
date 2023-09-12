//
//  ContentView.swift
//  Idyll
//
//  Created by Daniel Ma on 9/11/23.
//

import SwiftUI

let formatter = {
    var nf = NumberFormatter()
    nf.maximumFractionDigits = 0
    nf.minimumFractionDigits = 0
    nf.usesGroupingSeparator = true
    nf.groupingSeparator = ","
//    nf.numberStyle = .scientific
    return nf
}()

let fracForm = {
    var nf = NumberFormatter()
    nf.minimumFractionDigits = 2
    nf.maximumFractionDigits = 2
    return nf
}()

let sciForm = {
    let nf = NumberFormatter()
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.numberStyle = .scientific
    return nf
}()

func formatNumber(_ number: Double) -> String {
    if (number < 1000) {
        return formatter.string(for: number) ?? ""
    } else if (number < 1_000_000) {
        let thousands = fracForm.string(for: (number / 1000)) ?? ""
        return "\(thousands)K"
    } else if (number < 1_000_000_000) {
        let millis = fracForm.string(for: (number / 1_000_000)) ?? ""
        return "\(millis)M"
    } else {
        return sciForm.string(for: number) ?? ""
    }
}

struct ContentView: View {
    var totalAmt: Double
    var resources: [IdyllResource]
    var amounts: [Double]
    var purchasedAmounts: [Double]
    var buyResource: (_ idx: Int) -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(formatNumber(totalAmt)).font(.system(.title, design: .monospaced))
            
            Spacer()
            
            List(resources.indices, id: \.self) { index in
                let resource = resources[index]
                let amount = amounts[index]
                let purchasedAmount = purchasedAmounts[index]
                let currentCost = resource.currentCost(purchasedAmount)
//                let nextStep = resource.nextStep(purchasedAmount)
                
                let inThisStep = purchasedAmount - (resource.stepCount(purchasedAmount) * 10)
                
//                let _ = print("\(resource.emoji): purchasedAmount: \(purchasedAmount) — nextStep: \(nextStep) — inThisStep: \(inThisStep) — stepCount: \(resource.stepCount(purchasedAmount))")
                
                HStack {
                    VStack {
                        Text(resource.emoji)
                        Text(formatNumber(amount)).font(.system(.body, design: .monospaced))
                        
                        if resource.stepMultiplier(purchasedAmount) > 1 {
                            Text("x\(formatter.string(for: resource.stepMultiplier(purchasedAmount)) ?? "")").font(.caption)
                        }
                    }
                    ProgressView(value: inThisStep / 10, total: 1.0)
                    Button("Buy for \(formatNumber(currentCost))") { buyResource(index) }.disabled(currentCost > totalAmt)
                }
            }
            
        }.padding()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(totalAmt: 100, resources: idyllResources, amounts: idyllResources.map { _ in Double(0) }, purchasedAmounts: idyllResources.map { _ in Double(100) })
    }
}
