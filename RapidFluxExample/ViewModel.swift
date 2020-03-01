//
//  ViewModel.swift
//  RapidFluxExample
//
//  Created by Yohta Watanave on 2020/03/01.
//

import Foundation
import RapidFlux

class ViewModel: AutoGenerateViewModel {
    
    let initialState = State(request: .uninitialized)
    let errorTranslator: ErrorTranslator
    
    struct State {
        var request: Async<String>
    }
    
    init(errorTranslator: ErrorTranslator) {
        self.errorTranslator = errorTranslator
    }
}
