//
//  Cube.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

public enum EdgeLocation: Hashable {
    case topRight
    case topFront
    case topLeft
    case topBack
    case middleRightFront
    case middleLeftFront
    case middleLeftBack
    case middleRightBack
    case bottomRight
    case bottomFront
    case bottomLeft
    case bottomBack
}

public struct EdgePiece {
    public enum Orientation {
        case correct
        case flipped
    }

    public var location: EdgeLocation
    public var orientation: Orientation

    init(_ location: EdgeLocation, orientation: Orientation = .correct) {
        self.location = location
        self.orientation = orientation
    }
}

public enum CornerLocation: Hashable {
    case topRightFront
    case topLeftFront
    case topLeftBack
    case topRightBack
    case bottomRightFront
    case bottomLeftFront
    case bottomLeftBack
    case bottomRightBack
}

public struct CornerPiece {
    public enum Orientation {
        case correct
        case rotatedClockwise
        case rotatedCounterClockwise
    }

    public var location: CornerLocation
    public var orientation: Orientation

    public init(_ location: CornerLocation, orientation: Orientation = .correct) {
        self.location = location
        self.orientation = orientation
    }
}

public enum Face {
    case top
    case bottom
    case left
    case right
    case front
    case back

    static let all: [Face] = [.top, .bottom, .left, .right, .front, .back]
}

public struct Cube {
    public struct Pieces {
        static let numberOfEdges = 12
        static let numberOfCorners = 8

        // Keys: All the edge locations in the cube
        // Values: The edge piece located in such location
        public var edges: [EdgeLocation : EdgePiece]

        // Keys: All the corner locations in the cube
        // Values: The corner piece located in such location
        public var corners: [CornerLocation : CornerPiece]
    }

    public var pieces: Pieces {
        didSet {
            // Just perform a naive validation to check we have a piece for each location
            validateEdges()
            validateCorners()
        }
    }

    fileprivate func validateEdges() {
        assert(self.pieces.edges.count == Pieces.numberOfEdges)
        assert(Set(self.pieces.edges.keys).count == Pieces.numberOfEdges)
    }

    fileprivate func validateCorners() {
        assert(self.pieces.corners.count == Pieces.numberOfCorners)
        assert(Set(self.pieces.corners.keys).count == Pieces.numberOfCorners)
    }

    public static let unscrumbledCube = Cube()

    public init() {
        self.pieces = Pieces(
            edges: [
                .topRight: EdgePiece(.topRight),
                .topFront: EdgePiece(.topFront),
                .topLeft: EdgePiece(.topLeft),
                .topBack: EdgePiece(.topBack),
                .middleRightFront: EdgePiece(.middleRightFront),
                .middleLeftFront: EdgePiece(.middleLeftFront),
                .middleLeftBack: EdgePiece(.middleLeftBack),
                .middleRightBack: EdgePiece(.middleRightBack),
                .bottomRight: EdgePiece(.bottomRight),
                .bottomFront: EdgePiece(.bottomFront),
                .bottomLeft: EdgePiece(.bottomLeft),
                .bottomBack: EdgePiece(.bottomBack)
            ],
            corners: [
                .topRightFront: CornerPiece(.topRightFront),
                .topRightBack: CornerPiece(.topRightBack),
                .topLeftBack: CornerPiece(.topLeftBack),
                .topLeftFront: CornerPiece(.topLeftFront),
                .bottomRightFront: CornerPiece(.bottomRightFront),
                .bottomLeftFront: CornerPiece(.bottomLeftFront),
                .bottomLeftBack: CornerPiece(.bottomLeftBack),
                .bottomRightBack: CornerPiece(.bottomRightBack)
            ]
        )
    }
}

extension Cube: Equatable {
    public static func ==(lhs: Cube, rhs: Cube) -> Bool {
        return lhs.pieces == rhs.pieces
    }
}

extension Cube.Pieces: Equatable {
    public static func ==(lhs: Cube.Pieces, rhs: Cube.Pieces) -> Bool {
        return lhs.edges == rhs.edges && lhs.corners == rhs.corners
    }
}

extension EdgePiece: Equatable {
    public static func ==(lhs: EdgePiece, rhs: EdgePiece) -> Bool {
        return lhs.location == rhs.location && lhs.orientation == rhs.orientation
    }
}

extension CornerPiece: Equatable {
    public static func ==(lhs: CornerPiece, rhs: CornerPiece) -> Bool {
        return lhs.location == rhs.location && lhs.orientation == rhs.orientation
    }
}

extension EdgeLocation {
    static let all: Set<EdgeLocation> = [.topRight, .topFront, .topLeft, .topBack, .middleRightFront, .middleLeftFront, .middleLeftBack, .middleRightBack, .bottomRight, .bottomFront, .bottomLeft, .bottomBack]

    // Sorted clockwise
    static func locations(in face: Face) -> [EdgeLocation] {
        switch face {
        case .top: return [.topRight, .topFront, .topLeft, .topBack]
        case .bottom: return [.bottomFront, .bottomRight, .bottomBack, .bottomLeft]
        case .left: return [.topLeft, .middleLeftFront, .bottomLeft, .middleLeftBack]
        case .right: return [.topRight, .middleRightBack, .bottomRight, .middleRightFront]
        case .front: return [.topFront, .middleRightFront, .bottomFront, .middleLeftFront]
        case .back: return [.topBack, .middleLeftBack, .bottomBack, .middleRightBack]
        }
    }
}

extension CornerLocation {
    static let all: Set<CornerLocation> = [.topRightFront, .topLeftFront, .topLeftBack, .topRightBack, .bottomRightFront, .bottomLeftFront, .bottomLeftBack, .bottomRightBack]

    // Sorted clockwise
    static func locations(in face: Face) -> [CornerLocation] {
        switch face {
        case .top: return [.topRightFront, .topLeftFront, .topLeftBack, .topRightBack]
        case .bottom: return [.bottomLeftFront, .bottomRightFront, .bottomRightBack, .bottomLeftBack]
        case .left: return [.topLeftBack, .topLeftFront, .bottomLeftFront, .bottomLeftBack]
        case .right: return [.topRightFront, .topRightBack, .bottomRightBack, .bottomRightFront]
        case .front: return [.topLeftFront, .topRightFront, .bottomRightFront, .bottomLeftFront]
        case .back: return [.topRightBack, .topLeftBack, .bottomLeftBack, .bottomRightBack]
        }
    }
}

extension Cube {
    public var numberOfPiecesInCorrectLocation: Int {
        let unscrumbled = Cube.unscrumbledCube

        var count = 0

        for edgeLocation in EdgeLocation.all {
            if unscrumbled.pieces.edges[edgeLocation]!.location == self.pieces.edges[edgeLocation]!.location {
                count += 1
            }
        }

        for cornerLocation in CornerLocation.all {
            if unscrumbled.pieces.corners[cornerLocation]!.location == self.pieces.corners[cornerLocation]!.location {
                count += 1
            }
        }

        return count
    }

    // The total number of pieces that are in the correct location and orientation
    public var numberOfSolvedPieces: Int {
        let unscrumbled = Cube.unscrumbledCube

        var count = 0

        for edgeLocation in EdgeLocation.all {
            if unscrumbled.pieces.edges[edgeLocation]! == self.pieces.edges[edgeLocation]! {
                count += 1
            }
        }

        for cornerLocation in CornerLocation.all {
            if unscrumbled.pieces.corners[cornerLocation]! == self.pieces.corners[cornerLocation]! {
                count += 1
            }
        }

        return count
    }
}
