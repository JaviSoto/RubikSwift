//
//  Dictionary+Extensions.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

extension Dictionary {
    func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows -> [Key : Value] {
        var dictionary: [Key : Value] = Dictionary(minimumCapacity: self.count)

        for (key, value) in self where try isIncluded(key, value) {
            dictionary[key] = value
        }
        
        return dictionary
    }

    func mapValues<T>(_ transform: (Key, Value) throws -> T) rethrows -> [Key : T] {
        var dictionary: [Key : T] = [Key : T](minimumCapacity: self.count)

        for (key, value) in self {
            dictionary[key] = try transform(key, value)
        }

        return dictionary
    }
}
