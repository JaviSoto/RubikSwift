//
//  ViewController.swift
//  RubikSwiftTestApp
//
//  Created by Javier Soto on 10/29/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import UIKit
import RubikSwift

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        testGeneticsSolver(1000)
    }

    func testGeneticsSolver(_ generations: Int) {
        let scrambleMoves = Move.randomMoves(count: 20)
        let cube = Cube(applyingToSolvedCube: scrambleMoves)

        print("Cube: \(scrambleMoves)")

        let solver = Solver(scrambledCube: cube, individuals: 5000)

        for generation in 1...generations {
            autoreleasepool {
                solver.runGeneration()

                let fitnessByIndividuals = solver.fitnessByIndividuals

                if generation % 100 == 0 {
                    let averageFitness = avg(fitnessByIndividuals.map { $0.1 })
                    print("\(generation): \(fitnessByIndividuals.first!.0.algorithm) (\(fitnessByIndividuals.first!.1), avg \(averageFitness))")
                }
            }
        }
    }
}

fileprivate func avg(_ n: [Int]) -> Double {
    return Double(n.reduce(0, +)) / Double(n.count)
}

