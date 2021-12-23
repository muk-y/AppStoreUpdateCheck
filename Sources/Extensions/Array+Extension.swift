//
//  Array+Extension.swift
//  
//
//  Created by Mukesh Shakya on 23/12/2021.
//

import Foundation

extension Array {
    
    func element(at index: Int) -> Element? {
        if index < count && index >= .zero {
            return self[index]
        }
        return nil
    }
    
}
