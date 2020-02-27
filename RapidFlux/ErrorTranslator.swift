//
//  ErrorTranslator.swift
//  RapidFlux
//
//  Created by Yohta Watanave on 2020/02/27.
//

import Foundation

public protocol ErrorTranslator {
    func translate(error: Error) -> String
}

class ErrorTranslatorImpl: ErrorTranslator {
    
    func translate(error: Error) -> String {
        return "Error"
    }
    
}
