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
    nf.numberStyle = .decimal
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
    nf.exponentSymbol = "e"
    return nf
}()

let logForms: [ClosedRange<Double>: String] = [3...5: "K", 6...8: "M", 9...11: "B", 12...14: "T"]

let maxZeroesToShowSpecial = 15

func formatNumber(_ number: Double) -> String {
    let zeroes = log10(number).rounded(.down)
    if zeroes < 4 {
        return formatter.string(for: number) ?? ""
    } else if zeroes > 14 {
        return sciForm.string(for: number) ?? ""
    } else {
        let pair = logForms.enumerated().first(where: { $0.element.key.contains(zeroes) })

        if let pair = pair {
            let powZeroes = pair.element.key.lowerBound
            let count = fracForm.string(for: number / pow(10, powZeroes)) ?? ""
            return "\(count)\(pair.element.value)"
        } else {
            return "\(formatter.string(for: number) ?? "")??"
        }
    }
}

struct ContentView: View {
    var totalAmt: Double
    var resources: [IdyllResource]
    var amounts: [Double]
    var purchasedAmounts: [Double]
    var perSecond: Double
    var buyResource: (_ idx: Int) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .center) {
            Text(formatNumber(totalAmt)).font(.system(.title, design: .monospaced))
            Text("\(formatNumber(perSecond)) / second").font(.caption)

            List(resources.indices, id: \.self) { index in
                let resource = resources[index]

                if index == 0 || purchasedAmounts[index - 1] > 10 {
                    ResourceRow(resource: resource, amount: amounts[index], purchasedAmount: purchasedAmounts[index], buyResource: { buyResource(index) }, totalAmount: totalAmt)
                }
            }.listStyle(.plain)
        }.background(.regularMaterial)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(totalAmt: 100, resources: idyllResources, amounts: idyllResources.map { _ in Double(9000) }, purchasedAmounts: idyllResources.map { _ in Double(24) }, perSecond: 2000)
    }
}
