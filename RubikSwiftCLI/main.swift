//
//  main.swift
//  RubikSwiftCLI
//
//  Created by Javier Soto on 10/31/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation
import RubikSwift

// Best (16):
// scramble: Cube: [F', B, L, R', U2, B2, F', D, R, D', R, U2, B2, U2, D2, U', L2, D, R', F']
// solve (gen 6028, 18 minutes): New best: [R, B, U', F, B, F', D', L', B2, L2, D, L', F, L2, B, U, L, D2, B, U', R, U2, F2, U2, F, B', F, D', U2, F2, D2, B2, U, F', L, F', D, L2, R, L2, U2, F', R2, F, L2, D', L', B', U2, B2, D', F', B', U', L', B2, U2, F', R2, B2, L, U2, L2, U, F2, B, L, U, F2, U2, F', L, D2, U, L', B2, F2, R, B', U', R', L, U', B', L2, U2, R2, B', D2, L, R2, U', L', U', R, U2, R2, U', F2, B2, F', B', F2, B, F, L', B2, L', R', L2, U2, R] (16.0)
// Online visualization: https://rubiks3x3.com/algorithm/?moves=RBuFBfdl12DlF2BUL5BuR404FbFd4051UfLfD2R24f3F2dlb41dfbul14f31L42U0BLU04fL5Ul10RburLub243b5L3uluR43u01fb0BFl1lr24R&initmove=fBLr41fDRdR4145u2Drf

final class GeneticsTests {
    static func testGeneticsSolver() {
        let scrambleMoves = Move.randomMoves(count: 20)
        let cube = Cube(applyingToSolvedCube: scrambleMoves)

        print("Cube: \(scrambleMoves.sequenceString)")

        let populationSize = 5000
        let solver = Solver(scrambledCube: cube, populationSize: populationSize)

        var bestIndividual: (Individual, Fitness)?

        let start = Date()

        // print gens per minute
        for generation in 1...1000000 {
            autoreleasepool {
                solver.runGeneration()

                let fitnessByIndividuals = solver.fitnessByIndividuals

                if bestIndividual == nil || fitnessByIndividuals.first!.1 > bestIndividual!.1 {
                    bestIndividual = fitnessByIndividuals.first!

                    print("\(generation): New best: \(bestIndividual!.0.algorithm.sequenceString) (\(bestIndividual!.1))")
                }

                if generation % 100 == 0 {
                    let elapsed = Date().timeIntervalSince(start)
                    let algorithmsPerSecond = Double(generation * populationSize) / elapsed

                    let averageFitness = avg(fitnessByIndividuals.map({ $0.1 }).firstHalf)
                    print("\(generation) (avg fitness \(averageFitness), \(Int(algorithmsPerSecond)) algs/sec, \(Int(elapsed / 60)) min elapsed)")
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

GeneticsTests.testGeneticsSolver()
