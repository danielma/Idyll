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
            
            List(resources.indices, id: \.self) { index in
                let resource = resources[index]
                
                ResourceView(resource: resource, amount: amounts[index], purchasedAmount: purchasedAmounts[index], buyResource: { buyResource(index) }, totalAmount: totalAmt)
            }.listStyle(.plain)
        }.background(.regularMaterial)
    }
}

struct ResourceView: View {
    var resource: IdyllResource
    var amount: Double
    var purchasedAmount: Double
    var buyResource: () -> Void
    var totalAmount: Double
    
    var body: some View {
        let currentCost = resource.currentCost(purchasedAmount)
//                let nextStep = resource.nextStep(purchasedAmount)
        
        let inThisStep = purchasedAmount - (resource.stepCount(purchasedAmount) * 10)
        let stepMultiplier = resource.stepMultiplier(purchasedAmount)
        
//                let _ = print("\(resource.emoji): purchasedAmount: \(purchasedAmount) — nextStep: \(nextStep) — inThisStep: \(inThisStep) — stepCount: \(resource.stepCount(purchasedAmount))")
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(resource.emoji).font(.title2)
                        Text(stepMultiplier > 1 ? "x\(formatter.string(for: stepMultiplier) ?? "")" : "").font(.caption)
                    }
                    Text(formatNumber(amount)).font(.system(.body, design: .monospaced))
                }
                Spacer()
                Button { buyResource() } label: {
                    VStack {
                        Text(formatNumber(currentCost))
                        Text("Buy").font(.caption)
                    }.frame(width: 84)
                }.disabled(currentCost > totalAmount).buttonStyle(.borderedProminent)
            }
            ProgressView(value: inThisStep / 10, total: 1.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(totalAmt: 100, resources: idyllResources, amounts: idyllResources.map { _ in Double(0) }, purchasedAmounts: idyllResources.map { _ in Double(2) })
    }
}
