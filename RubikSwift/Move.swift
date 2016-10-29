//
//  Move.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

public prefix func !(orientation: EdgePiece.Orientation) -> EdgePiece.Orientation {
    switch orientation {
    case .correct: return .flipped
    case .flipped: return .correct
    }
}

extension EdgePiece {
    mutating func flip() {
        self.orientation = !self.orientation
    }

    var flipped: EdgePiece {
        var piece = self
        piece.flip()

        return piece
    }
}

public func +(lhs: CornerPiece.Orientation, rhs: CornerPiece.Orientation) -> CornerPiece.Orientation {
    switch (lhs, rhs) {
    case (.correct, .correct): return .correct
    case (.correct, .rotatedClockwise), (.rotatedClockwise, .correct): return .rotatedClockwise
    case (.correct, .rotatedCounterClockwise), (.rotatedCounterClockwise, .correct): return .rotatedCounterClockwise
    case (.rotatedClockwise, .rotatedCounterClockwise), (.rotatedCounterClockwise, .rotatedClockwise): return .correct
    case (.rotatedClockwise, .rotatedClockwise): return .rotatedCounterClockwise
    case (.rotatedCounterClockwise, .rotatedCounterClockwise): return .rotatedClockwise
    }
}

public func +(lhs: CornerPiece, rhs: CornerPiece.Orientation) -> CornerPiece {
    return CornerPiece(lhs.location, orientation: lhs.orientation + rhs)
}

public struct Move {
    public enum Magnitude {
        case clockwiseQuarterTurn
        case halfTurn
        case counterClockwiseQuarterTurn

        static let all: [Magnitude] = [.clockwiseQuarterTurn, .halfTurn, .counterClockwiseQuarterTurn]

        var opposite: Magnitude {
            switch self {
            case .clockwiseQuarterTurn: return .counterClockwiseQuarterTurn
            case .counterClockwiseQuarterTurn: return .clockwiseQuarterTurn
            case .halfTurn: return .halfTurn
            }
        }
    }

    public let face: Face
    public let magnitude: Magnitude

    var opposite: Move {
        return Move(face: self.face, magnitude: self.magnitude.opposite)
    }
}

extension Move.Magnitude {
    // This allows us to only model clockwise turns, and apply the rest of them as a succesion of clockwise turns.
    var numberOfClockwiseQuarterTurns: Int {
        switch self {
        case .clockwiseQuarterTurn: return 1
        case .halfTurn: return 2
        case .counterClockwiseQuarterTurn: return 3
        }
    }
}

// These are based on the relative notion based on my method to solve the cube blind-folded
// The top and bottom faces are considered strong.
// Front and back are considered regular.
// Left and right are considered weak.
// A "sticker" of strong color or regular color in a strong or regular face is considered correct orientation.
// A "sticker" of a weak color in a strong or regular face is considered in incorrect orientation.
extension Face {
    var clockwiseTurnAffectsEdgeOrientation: Bool {
        switch self {
        case .top, .bottom: return false
        case .left, .right: return true
        case .front, .back: return false
        }
    }

    func cornerOrientationChangeAfterClockwiseTurn(in location: CornerLocation) -> CornerPiece.Orientation {
        switch self {
        case .top, .bottom: return .correct
        case .front:
            switch location {
            case .topLeftFront, .bottomRightFront: return .rotatedClockwise
            case .topRightFront, .bottomLeftFront: return .rotatedCounterClockwise
            default: fatalError("Invalid location for the front face")
            }
        case .back:
            switch location {
            case .topLeftBack, .bottomLeftBack: return .rotatedCounterClockwise
            case .topRightBack, .bottomRightBack: return .rotatedClockwise
            default: fatalError("Invalid location for the back face")
            }
        case .left:
            switch location {
            case .topLeftFront, .topLeftBack: return .rotatedClockwise
            case .bottomLeftFront, .bottomLeftBack: return .rotatedCounterClockwise
            default: fatalError("Invalid location for the left face")
            }
        case .right:
            switch location {
            case .topRightFront, .topRightBack: return .rotatedClockwise
            case .bottomRightFront, .bottomRightBack: return .rotatedCounterClockwise
            default: fatalError("Invalid location for the right face")
            }
        }
    }
}

extension Cube {
    public mutating func apply(_ move: Move) {
        self.apply([move])
    }

    public mutating func apply(_ moves: [Move]) {
        for move in moves {
            for _ in 1...move.magnitude.numberOfClockwiseQuarterTurns {
                // 1. Alter orientation
                if move.face.clockwiseTurnAffectsEdgeOrientation {
                    self.flipEdges(in: move.face)
                }

                self.rotateCorners(in: move.face)

                // 2. Move
                self.rotatePiecesClockwise(in: move.face)
            }
        }
    }
}

extension Cube {
    mutating func flipEdges(in face: Face) {
        self.pieces.edges.map { face.contains($0) ? $1.flipped : $1 }
    }

    mutating func rotateCorners(in face: Face) {
        self.pieces.corners.map { (location: CornerLocation, corner: CornerPiece) -> CornerPiece in
            guard face.contains(location) else { return corner }

            let rotation = face.cornerOrientationChangeAfterClockwiseTurn(in: location)

            return corner + rotation
        }
    }

    mutating func rotatePiecesClockwise(in face: Face) {
        var rotatedPieces = self.pieces

        let edgeLocations = EdgeLocation.locations(in: face)
        let cornerLocations = CornerLocation.locations(in: face)

        // This relies on the fact that the locations are returned in clockwise order
        for (index, edgeLocation) in edgeLocations.enumerated() {
            rotatedPieces.edges[edgeLocations[wrapping: index + 1]] = self.pieces.edges[edgeLocation]
        }

        for (index, cornerLocation) in cornerLocations.enumerated() {
            rotatedPieces.corners[cornerLocations[wrapping: index + 1]] = self.pieces.corners[cornerLocation]
        }

        self.pieces = rotatedPieces
    }
}

extension Move.Magnitude: CustomStringConvertible {
    public var description: String {
        switch self {
        case .clockwiseQuarterTurn: return ""
        case .counterClockwiseQuarterTurn: return "'"
        case .halfTurn: return "2"
        }
    }
}

extension Move: CustomStringConvertible {
    public var description: String {
        return "\(self.face)\(self.magnitude)"
    }
}

extension Collection where Iterator.Element == Move {
    var description: String {
        return self.map { $0.description }.joined(separator: " ")
    }
}
