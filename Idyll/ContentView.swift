//
//  ContentView.swift
//  Idyll
//
//  Created by Daniel Ma on 9/11/23.
//

import SwiftUI

struct ContentView: View {
    var totalAmt: Double
    var resources: [IdyllResource]
    var amounts: [Double]
    var purchasedAmounts: [Double]
    var buyResource: (_ idx: Int) -> Void = { _ in }

    var body: some View {
        List(resources.indices, id: \.self) { index in
            let resource = resources[index]

            if index == 0 || purchasedAmounts[index - 1] > 10 {
                ResourceRow(resource: resource, amount: amounts[index], purchasedAmount: purchasedAmounts[index], buyResource: { buyResource(index) }, totalAmount: totalAmt)
            }
        }.listStyle(.plain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(totalAmt: 100, resources: Array(idyllResources[0 ... 2]), amounts: idyllResources.map { _ in Double(9000) }, purchasedAmounts: idyllResources.map { _ in Double(24) })
    }
}
