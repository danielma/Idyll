//
//  NumberUtils.swift
//  Idyll
//
//  Created by Daniel Ma on 9/13/23.
//

import Foundation
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
