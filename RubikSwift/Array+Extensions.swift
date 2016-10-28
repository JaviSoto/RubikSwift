//
//  Array+Extensions.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

extension Array {
    subscript(wrapping index: Int) -> Element {
        get {
            let wrappedIndex = index % count
            return self[wrappedIndex]
        }
    }
}
