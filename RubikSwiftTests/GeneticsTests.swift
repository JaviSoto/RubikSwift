//
//  GeneticsTests.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import XCTest
@testable import RubikSwift

// Best (15):
// scramble: Cube: [U, R2, D2, B, D, R2, F', L2, F', L2, F', U', R', L, F2, L2, R', L, B, L2]
// solve (gen 42655, 69 minutes): New best: [B, L2, B, R2, F', L2, F', D', B', D', U, F2, B2, F2, B', R2, D', F, U', D', U', R', F', R, R2, F', R, L', R, U2, B, U, B', L, D2, U2, D, U, D, L', U, L2, R, L', R'] (15.0)

class GeneticsTests: XCTestCase {
    func testGeneticsSolver() {
        let scrambleMoves = Move.randomMoves(count: 20)
        let cube = Cube(applyingToSolvedCube: scrambleMoves)

        print("Cube: \(scrambleMoves)")

        let solver = Solver(scrambledCube: cube, populationSize: 2000)

        var bestIndividual: (Individual, Fitness)?

        let start = Date()

        // print gens per minute
        for generation in 1...1000000 {
            autoreleasepool {
                solver.runGeneration()

                let fitnessByIndividuals = solver.fitnessByIndividuals

                if bestIndividual == nil || fitnessByIndividuals.first!.1 > bestIndividual!.1 {
                    bestIndividual = fitnessByIndividuals.first!

                    print("\(generation): New best: \(bestIndividual!.0.algorithm) (\(bestIndividual!.1))")
                }

                if generation % 50 == 0 {
                    let elapsed = Date().timeIntervalSince(start)
                    let elapsedMinutes = elapsed / 60
                    let generationsPerMinute = Double(generation) / elapsedMinutes

                    let averageFitness = avg(fitnessByIndividuals.map({ $0.1 }).firstHalf)
                    print("\(generation) (avg fitness \(averageFitness), \(Int(generationsPerMinute)) gens/min, \(Int(elapsedMinutes)) min elapsed)")
                }
            }
        }
    }
}

extension Array {
    var firstHalf: [Element] {
        return Array(self[0..<self.endIndex / 2])
    }
}

fileprivate func avg(_ n: [Fitness]) -> Double {
    return Double(n.reduce(0, +)) / Double(n.count)
}
