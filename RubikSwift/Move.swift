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

public prefix func !(orientation: CornerPiece.Orientation) -> CornerPiece.Orientation {
    switch orientation {
    case .correct: return .correct
    case .rotatedClockwise: return .rotatedCounterClockwise
    case .rotatedCounterClockwise: return .rotatedClockwise
    }
}

public func -(lhs: CornerPiece.Orientation, rhs: CornerPiece.Orientation) -> CornerPiece.Orientation {
    return lhs + !rhs
}

public func +(lhs: CornerPiece, rhs: CornerPiece.Orientation) -> CornerPiece {
    return CornerPiece(lhs.location, orientation: lhs.orientation + rhs)
}

public func -(lhs: CornerPiece, rhs: CornerPiece.Orientation) -> CornerPiece {
    return CornerPiece(lhs.location, orientation: lhs.orientation - rhs)
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

    public var opposite: Move {
        return Move(face: self.face, magnitude: self.magnitude.opposite)
    }
}

// These are based on the relative notion based on my method to solve the cube blind-folded
// The top and bottom faces are considered strong.
// Front and back are considered regular.
// Left and right are considered weak.
// A "sticker" of strong color or regular color in a strong or regular face is considered correct orientation.
// A "sticker" of a weak color in a strong or regular face is considered in incorrect orientation.
extension Face {
    var quarterTurnAffectsEdgeOrientation: Bool {
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
            case .topRightFront, .bottomLeftFront: return .rotatedCounterClockwise
            case .topLeftFront, .bottomRightFront: return .rotatedClockwise
            default: fatalError("Invalid location for the front face")
            }
        case .back:
            switch location {
            case .topRightBack, .bottomLeftBack: return .rotatedClockwise
            case .topLeftBack, .bottomRightBack: return .rotatedCounterClockwise
            default: fatalError("Invalid location for the back face")
            }
        case .left:
            switch location {
            case .topLeftFront, .bottomLeftBack: return .rotatedCounterClockwise
            case .topLeftBack, .bottomLeftFront: return .rotatedClockwise
            default: fatalError("Invalid location for the left face")
            }
        case .right:
            switch location {
            case .topRightFront, .bottomRightBack: return .rotatedClockwise
            case .topRightBack, .bottomRightFront: return .rotatedCounterClockwise
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
        // Handle half turns as 2 clockwise turns
        let effectiveMoves = moves.flatMap { move -> [Move] in
            var move = move

            if move.magnitude == .halfTurn {
                move = Move(face: move.face, magnitude: .clockwiseQuarterTurn)

                return [move, move]
            }
            else {
                return [move]
            }
        }

        for move in effectiveMoves {
            precondition(move.magnitude != .halfTurn)

            let shouldFlipEdges = move.face.quarterTurnAffectsEdgeOrientation

            // 1. Alter orientation
            if shouldFlipEdges {
                self.flipEdges(in: move.face)
            }

            let clockwiseTurn = move.magnitude == .clockwiseQuarterTurn

            self.rotateCorners(in: move.face)

            // 2. Permute
            self.permutatePieces(in: move.face, clockwise: clockwiseTurn)
        }
    }

    public func applying(_ moves: [Move]) -> Cube {
        var cube = self
        cube.apply(moves)

        return cube
    }
}

extension Cube {
    mutating func flipEdges(in face: Face) {
        self.pieces.edges.map(face) { $1.flipped }
    }

    mutating func rotateCorners(in face: Face) {
        self.pieces.corners.map(face) { (location: CornerLocation, corner: CornerPiece) -> CornerPiece in
            let rotation = face.cornerOrientationChangeAfterClockwiseTurn(in: location)

            return corner + rotation
        }
    }

    mutating func permutatePieces(in face: Face, clockwise: Bool) {
        var rotatedPieces = self.pieces

        // This relies on the fact that the locations are returned in clockwise order
        var edgeLocations = EdgeLocation.locations(in: face)
        var cornerLocations = CornerLocation.locations(in: face)

        if !clockwise {
            edgeLocations.reverse()
            cornerLocations.reverse()
        }

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

extension Move {
    public init?(_ string: String) {
        guard string.characters.count <= 2 else { return nil }
        guard let firstCharacter = string.characters.first.map( { String($0) }) else { return nil }

        let face: Face
        let magnitude: Magnitude

        switch firstCharacter {
        case "U": face = .top
        case "D": face = .bottom
        case "L": face = .left
        case "R": face = .right
        case "F": face = .front
        case "B": face = .back
        default: return nil
        }

        if string.characters.count > 1 {
            switch string.characters.last {
            case .none: magnitude = .clockwiseQuarterTurn
            case .some("'"): magnitude = .counterClockwiseQuarterTurn
            case .some("2"): magnitude = .halfTurn
            default: return nil
            }
        } else {
            magnitude = .clockwiseQuarterTurn
        }

        self = Move(face: face, magnitude: magnitude)
    }

    public static func moves(_ string: String) -> [Move]? {
        let moveStrings = string.components(separatedBy: " ")

        let moves = moveStrings.flatMap(Move.init)

        guard moves.count == moveStrings.count else {
            return nil
        }
        
        return moves
    }
}

extension Collection where Iterator.Element == Move {
    public var opposite: [Move] {
        return self.reversed().map { $0.opposite }
    }
}

extension Move: CustomStringConvertible {
    public var description: String {
        return "\(self.face)\(self.magnitude)"
    }
}

extension Collection where Iterator.Element == Move {
    public var sequenceString: String {
        return self.map { $0.description }.joined(separator: " ")
    }
}
