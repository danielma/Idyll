//
//  ResourceRow.swift
//  Idyll
//
//  Created by Daniel Ma on 9/12/23.
//

import Foundation
import SwiftUI

struct ResourceRow: View {
    var resource: IdyllResource
    var amount: Double
    var purchasedAmount: Double
    var buyResource: () -> Void
    var totalAmount: Double
    
    var body: some View {
        let currentCost = resource.currentCost(purchasedAmount)
        
        let inThisStep = purchasedAmount - (resource.stepCount(purchasedAmount) * 10)
        let stepMultiplier = resource.stepMultiplier(purchasedAmount)
        
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(resource.emoji).font(.title2)
                        Text(stepMultiplier > 1 ? "×\(formatter.string(for: stepMultiplier) ?? "")" : "").font(.caption)
                    }
                    Text(formatNumber(amount)).font(.system(.body, design: .monospaced))
                }
                Spacer()
                Button { buyResource() } label: {
                    VStack {
                        Text(formatNumber(currentCost))
                        Text("Buy").font(.caption)
                    }.frame(width: 84)
                }.buttonStyle(.borderedProminent).disabled(currentCost > totalAmount) // .foregroundStyle(.foreground)
            }
            ProgressView(value: inThisStep / 10, total: 1.0)
        }
    }
}

struct ResourceRow_Previews: PreviewProvider {
    static var previews: some View {
        List([idyllResources[0], idyllResources[1]], id: \.id) { resource in
            
            ResourceRow(resource: resource, amount: 200, purchasedAmount: 17, buyResource: {}, totalAmount: 6000)
        }.listStyle(.plain)
        
        ResourceRow(resource: idyllResources[0], amount: 1000, purchasedAmount: 30, buyResource: {}, totalAmount: 1000)
    }
}
