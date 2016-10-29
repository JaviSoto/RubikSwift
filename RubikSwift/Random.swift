//
//  Random.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

extension Array {
    var random: Element {
        return self[Int(arc4random_uniform(UInt32(self.count - 1)))]
    }
}

extension Move {
    public static var random: Move {
        return Move(face: Face.all.random, magnitude: Magnitude.all.random)
    }

    static func randomMoves(count: Int) -> [Move] {
        var moves: [Move] = []

        while moves.count < count {
            let move = Move.random

            guard moves.last?.face != move.face else {
                continue
            }
            
            moves.append(move)
        }
        
        return moves
    }
    
}
