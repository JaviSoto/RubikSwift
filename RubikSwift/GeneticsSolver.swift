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
    public let scrambledCube: Cube
    fileprivate let populationSize: Int

    public private(set) var currentGeneration = 0

    // Always sorted by fitness
    public private(set) var fitnessByIndividuals: [(Individual, Fitness)] = []

    public init(scrambledCube: Cube, populationSize: Int) {
        self.scrambledCube = scrambledCube
        self.populationSize = populationSize
    }

    public func runGeneration() {
        // Current approach:
        // Kill 75% of the "worst" algorithms
        // Take the top 10% and create 25 mutations for each (we keep the original 10% as well)
        // Take the remaining 90% and create some mutations for them too, enough to go back to self.populationSize

        let percentageOfIndividualsToKill = 0.80
        let percentageOfTopIndividualsToHaveIncreasedOffspring = 0.10
        let numberOfOffspringForTopIndividuals = 25

        let numberOfIndividualsToKill = Int(Double(self.populationSize) * percentageOfIndividualsToKill)
        let populationSizeAfterSelection = self.populationSize - numberOfIndividualsToKill
        let numberOfIndividualsToHaveIncreasedOffspring = Int(Double(populationSizeAfterSelection) * percentageOfTopIndividualsToHaveIncreasedOffspring)
        let numberOfOtherIndividuals = populationSizeAfterSelection - numberOfIndividualsToHaveIncreasedOffspring
        let numberOfTopOffspring = numberOfIndividualsToHaveIncreasedOffspring * numberOfOffspringForTopIndividuals
        let numberOfOffspringForRemainingIndividuals = Int(ceil(Double(self.populationSize - numberOfIndividualsToHaveIncreasedOffspring - numberOfTopOffspring - numberOfOtherIndividuals) / Double(numberOfOtherIndividuals)))

        var individuals = self.fitnessByIndividuals.map { $0.0 }

        if individuals.isEmpty {
            // Initial population
            individuals = Individual.createRandom(self.populationSize)
        }
        else {
            // Survival of the fittest
            individuals.removeLast(numberOfIndividualsToKill)

            // Mutations
            let topIndividuals = individuals.prefix(upTo: numberOfIndividualsToHaveIncreasedOffspring)
            let remainingIndividuals = individuals.suffix(from: numberOfIndividualsToHaveIncreasedOffspring)

            let topIndividualsOffspring = Array(repeating: topIndividuals, count: numberOfOffspringForTopIndividuals).flatMap { $0 }
            let remainingIndividualsOffspring = Array(repeating: remainingIndividuals, count: numberOfOffspringForRemainingIndividuals).flatMap { $0 }

            let mutants = (topIndividualsOffspring + remainingIndividualsOffspring).prefix(upTo: self.populationSize - individuals.count).map { $0.mutate () }
            individuals.append(contentsOf: mutants)
        }

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
    fileprivate static func createRandom(_ count: Int) -> [Individual] {
        let initialAlgorithmLength = 1

        return (0..<count).map { _ in return Individual(algorithm: Move.randomMoves(count: initialAlgorithmLength)) }
    }
}

extension Individual {
    fileprivate func fitness(solvingCube cube: Cube) -> Fitness {
        var cubeAfterApplyingAlgorithm = cube
        cubeAfterApplyingAlgorithm.apply(self.algorithm)

        return Fitness(cubeAfterApplyingAlgorithm.numberOfSolvedPieces)
    }
}

extension Individual {
    fileprivate static let chancesOfMoveRemoval = 1
    fileprivate static let chancesOfMoveAddition = 100
    // Variate these depending on the "stage" of the solution?
    fileprivate static let minMovesToAdd = 7
    fileprivate static let maxMovesToAdd = 25
    fileprivate static let chancesOfMoveAdditionHappensAtRandomIndex = 1

    func mutate() -> Individual {
        var algorithm = self.algorithm

        let randomNumber = Int.random(in: 1...100)

        let removeMove = randomNumber <= Individual.chancesOfMoveRemoval
        if removeMove {
            algorithm.remove(at: Array(algorithm.indices).count - 1)
        }

        let addMoves = randomNumber <= Individual.chancesOfMoveAddition
        if addMoves {
            let movesToAdd = Move.randomMoves(count: Int.random(in: Individual.minMovesToAdd...Individual.maxMovesToAdd))

            let insertAtRandomIndex = randomNumber <= Individual.chancesOfMoveAdditionHappensAtRandomIndex && !algorithm.isEmpty
            let index = insertAtRandomIndex ? Int.random(in: algorithm.startIndex...algorithm.endIndex) : algorithm.endIndex

            algorithm.insert(contentsOf: movesToAdd, at: index)
        }

        return Individual(algorithm: algorithm)
    }
}
