//
//  GeneticsTests.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import XCTest
@testable import RubikSwift

// Best:
// scramble: [U2, R', L', U2, F', R2, U, R, U2, F2, R', L2, B', U', F2, R2, L, D2, F2, U', R', B, U2, F2, R', B2, R', D2, R', U', D, B2, D2, L', D, R', U2, B', L, B2, F, B', F', L, D', B', U', F, D2, F']
// solve: [B', L, R', U', D2, B2, B2, U', D, B', R, F, R, R2, F', R, F', D', F, D2, L, R, F', L', R', D2, F2, L, D, L2, F, L2, D]: 14.4

class GeneticsTests: XCTestCase {
    func testGeneticsSolver() {
        let scrambleMoves = Move.randomMoves(count: 50)
        let cube = Cube(applyingToSolvedCube: scrambleMoves)

        print("Cube: \(scrambleMoves)")

        let solver = Solver(scrambledCube: cube, individuals: 100)

        for generation in 1...50000 {
            solver.runGeneration()

            let fitnessByIndividuals = solver.fitnessByIndividuals

            if generation % 100 == 0 {
                let averageFitness = avg(fitnessByIndividuals.map { $0.1 })
                print("\(generation): \(fitnessByIndividuals.first!.0.algorithm) (\(fitnessByIndividuals.first!.1), avg \(averageFitness))")
            }
        }
    }
}

fileprivate func avg(_ n: [Double]) -> Double {
    return n.reduce(0, +) / Double(n.count)
}
