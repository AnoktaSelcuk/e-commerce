//
//  HelperFunction.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
    
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    
    return currencyFormatter.string(from: NSNumber(value: number))!
}
