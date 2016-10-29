//
//  GeneticsSolver.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

public typealias Algorithm = [Move]
public typealias Fitness = Double

public final class Solver {
    fileprivate let scrambledCube: Cube
    fileprivate let numberOfIndividuals: Int

    public private(set) var currentGeneration = 0

    public private(set) var individuals: [Individual] = []

    public init(scrambledCube: Cube, individuals: Int) {
        self.scrambledCube = scrambledCube
        self.numberOfIndividuals = individuals
    }

    fileprivate func makeRandomIndividuals(_ count: Int) -> [Individual] {
        let initialAlgorithmLength = 15

        return (0..<count).map { _ in return Individual(algorithm: Move.randomMoves(count: initialAlgorithmLength)) }
    }

    public func runGeneration() {
        let numberOfIndividualsToKill = Int(Double(self.numberOfIndividuals) / 1.3)

        self.individuals = self.fitnessByIndividuals.map { $0.0 }

        if !self.individuals.isEmpty {
            self.individuals.removeLast(numberOfIndividualsToKill)
        }

        let mutate = self.individuals + self.individuals
        self.individuals.append(contentsOf: mutate.map { $0.mutate() })

        // Add random ones to keep the population constant
        if self.individuals.count < self.numberOfIndividuals {
            self.individuals.append(contentsOf: (self.makeRandomIndividuals(self.numberOfIndividuals - self.individuals.count)))
        }

        self.currentGeneration += 1
    }

    private let serialQueue = DispatchQueue(label: "es.javisoto.GeneticsSolver.serial")

    public var fitnessByIndividuals: [(Individual, Fitness)] {
        var fitnessByIndividuals: [(Individual, Fitness)] = []

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.concurrentPerform(iterations: self.individuals.count) { index in
            group.enter()
            let individual = self.individuals[index]
            let fitness = individual.fitness(solvingCube: self.scrambledCube)

            serialQueue.async() {
                fitnessByIndividuals.append(individual, fitness)
                group.leave()
            }
        }
        group.leave()
        group.wait()

        return fitnessByIndividuals.sorted { $0.1 > $1.1 }
    }
}

public final class Individual {
    // public let ID = UUID()
    public fileprivate(set) var algorithm: Algorithm

    init(algorithm: Algorithm) {
        self.algorithm = algorithm
    }
}

extension Individual {
    // TODO: Half way through the cube could be solved, maybe stop at every step and check?
    fileprivate func fitness(solvingCube cube: Cube) -> Fitness {
        var cubeAfterApplyingAlgorithm = cube
        cubeAfterApplyingAlgorithm.apply(self.algorithm)

        return Double(cubeAfterApplyingAlgorithm.numberOfSolvedPieces)
    }
}

extension Individual {
    fileprivate static let chancesOfMoveRemoval = 60
    fileprivate static let chancesOfMoveAddition = 90
    fileprivate static let maxMovesToAdd = 20
    fileprivate static let chancesOfMoveAdditionHappensAtRandomIndex = 90

    func mutate() -> Individual {
        let individual = Individual(algorithm: self.algorithm)

        let randomNumber = Int(arc4random() % 100)

        if randomNumber <= Individual.chancesOfMoveRemoval {
            individual.algorithm.remove(at: Array(individual.algorithm.indices).count - 1)
        }

        if randomNumber <= Individual.chancesOfMoveAddition {
            let movesToAdd = Move.randomMoves(count: Int(arc4random_uniform(UInt32(Individual.maxMovesToAdd))) + 1)

            for move in movesToAdd {
                let index = randomNumber <= Individual.chancesOfMoveAdditionHappensAtRandomIndex && !individual.algorithm.isEmpty ? Array(individual.algorithm.indices).random : individual.algorithm.endIndex

                individual.algorithm.insert(move, at: index)
            }
        }

        return individual
    }
}
