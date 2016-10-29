//
//  GeneticsSolver.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

public typealias Algorithm = [Move]
public typealias Fitness = Int

public final class Solver {
    public let scrambledCube: Cube
    fileprivate let numberOfIndividuals: Int

    public private(set) var currentGeneration = 0

    // Always sorted by fitness
    public private(set) var fitnessByIndividuals: [(Individual, Fitness)] = []

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

        if !self.fitnessByIndividuals.isEmpty {
            self.fitnessByIndividuals.removeLast(numberOfIndividualsToKill)
        }

        var individuals = self.fitnessByIndividuals.map { $0.0 }

        let mutate = individuals + individuals
        individuals.append(contentsOf: mutate.map { $0.mutate() })

        // Add random ones to keep the population constant
        precondition(individuals.count < self.numberOfIndividuals)
        individuals.append(contentsOf: (self.makeRandomIndividuals(self.numberOfIndividuals - individuals.count)))

        self.fitnessByIndividuals = self.calculateFitnessByIndividuals(individuals)
        self.currentGeneration += 1
    }

    private let serialQueue = DispatchQueue(label: "es.javisoto.GeneticsSolver.serial")

    // Returns the list of individuals and their fitness sorted by their descending fitness
    private func calculateFitnessByIndividuals(_ individuals: [Individual]) -> [(Individual, Fitness)] {
        var fitnessByIndividuals: [(Individual, Fitness)] = []

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.concurrentPerform(iterations: individuals.count) { index in
            group.enter()
            let individual = individuals[index]
            let fitness = individual.fitness(solvingCube: self.scrambledCube)

            let individualWithFitness = (individual, fitness)

            serialQueue.async() {
                let indexToInsertAt = fitnessByIndividuals.indexOfLastElement(biggerThan: individualWithFitness) { $0.1 > fitness }

                fitnessByIndividuals.insert(individualWithFitness, at: indexToInsertAt ?? 0)
                group.leave()
            }
        }
        group.leave()
        group.wait()

        return fitnessByIndividuals
    }
}

extension Array {
    fileprivate func indexOfLastElement(biggerThan element: Element, isBigger: (Element) -> Bool) -> Int? {
        var left = self.startIndex
        var right = self.endIndex - 1

        var indexOfLastSmallerElement: Int? = nil

        while left <= right {
            let currentIndex = (left + right) / 2
            let candidate = self[currentIndex]

            if isBigger(candidate) {
                left = currentIndex + 1
                indexOfLastSmallerElement = currentIndex + 1
            } else {
                right = currentIndex - 1
            }
        }
        
        return indexOfLastSmallerElement
    }
}

public final class Individual {
    // public let ID = UUID()
    public let algorithm: Algorithm

    init(algorithm: Algorithm) {
        self.algorithm = algorithm
    }
}

extension Individual {
    // TODO: Half way through the cube could be solved, maybe stop at every step and check?
    fileprivate func fitness(solvingCube cube: Cube) -> Fitness {
        var cubeAfterApplyingAlgorithm = cube
        cubeAfterApplyingAlgorithm.apply(self.algorithm)

        return cubeAfterApplyingAlgorithm.numberOfSolvedPieces
    }
}

extension Individual {
    fileprivate static let chancesOfMoveRemoval = 10
    fileprivate static let chancesOfMoveAddition = 100
    fileprivate static let maxMovesToAdd = 30
    fileprivate static let minMovesToAdd = 10
    fileprivate static let chancesOfMoveAdditionHappensAtRandomIndex = 10

    func mutate() -> Individual {
        var algorithm = self.algorithm

        let randomNumber = Int.random(in: 0...100)

        let removeMove = randomNumber <= Individual.chancesOfMoveRemoval
        if removeMove {
            algorithm.remove(at: Array(algorithm.indices).count - 1)
        }

        let addMoves = randomNumber <= Individual.chancesOfMoveAddition
        if addMoves {
            let movesToAdd = Move.randomMoves(count: Int.random(in: Individual.minMovesToAdd...Individual.maxMovesToAdd))

            for move in movesToAdd {
                let insertAtRandomIndex = randomNumber <= Individual.chancesOfMoveAdditionHappensAtRandomIndex && !algorithm.isEmpty
                let index = insertAtRandomIndex ? Int.random(in: algorithm.startIndex...algorithm.endIndex) : algorithm.endIndex

                algorithm.insert(move, at: index)
            }
        }

        return Individual(algorithm: algorithm)
    }
}
