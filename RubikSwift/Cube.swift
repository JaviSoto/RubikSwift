//
//  Cube.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import Foundation

public enum EdgeLocation {
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

public enum CornerLocation {
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

public struct EdgePieceCollection {
    var topRight: EdgePiece
    var topFront: EdgePiece
    var topLeft: EdgePiece
    var topBack: EdgePiece
    var middleRightFront: EdgePiece
    var middleLeftFront: EdgePiece
    var middleLeftBack: EdgePiece
    var middleRightBack: EdgePiece
    var bottomRight: EdgePiece
    var bottomFront: EdgePiece
    var bottomLeft: EdgePiece
    var bottomBack: EdgePiece

    subscript(location: EdgeLocation) -> EdgePiece {
        get {
            switch location {
            case .topRight: return self.topRight
            case .topFront: return self.topFront
            case .topLeft: return self.topLeft
            case .topBack: return self.topBack
            case .middleRightFront: return self.middleRightFront
            case .middleLeftFront: return self.middleLeftFront
            case .middleLeftBack: return self.middleLeftBack
            case .middleRightBack: return self.middleRightBack
            case .bottomRight: return self.bottomRight
            case .bottomFront: return self.bottomFront
            case .bottomLeft: return self.bottomLeft
            case .bottomBack: return self.bottomBack
            }
        }
        set {
            switch location {
            case .topRight: self.topRight = newValue
            case .topFront: self.topFront = newValue
            case .topLeft: self.topLeft = newValue
            case .topBack: self.topBack = newValue
            case .middleRightFront: self.middleRightFront = newValue
            case .middleLeftFront: self.middleLeftFront = newValue
            case .middleLeftBack: self.middleLeftBack = newValue
            case .middleRightBack: self.middleRightBack = newValue
            case .bottomRight: self.bottomRight = newValue
            case .bottomFront: self.bottomFront = newValue
            case .bottomLeft: self.bottomLeft = newValue
            case .bottomBack: self.bottomBack = newValue
            }
        }
    }

    mutating func map(_ face: Face, _ f: (EdgeLocation, EdgePiece) -> EdgePiece) {
        for location in EdgeLocation.locations(in: face) {
            let piece = self[location]
            let newPiece = f(location, piece)

            if newPiece != piece {
                self[location] = newPiece
            }
        }
    }

    public var all: [EdgePiece] {
        return [self.topRight, self.topFront, self.topLeft, self.topBack, self.middleRightFront, self.middleLeftFront, self.middleLeftBack, self.middleRightBack, self.bottomRight, self.bottomFront, self.bottomLeft, self.bottomBack]
    }
}

public struct CornerPieceCollection {
    var topRightFront: CornerPiece
    var topLeftFront: CornerPiece
    var topLeftBack: CornerPiece
    var topRightBack: CornerPiece
    var bottomRightFront: CornerPiece
    var bottomLeftFront: CornerPiece
    var bottomLeftBack: CornerPiece
    var bottomRightBack: CornerPiece

    subscript(location: CornerLocation) -> CornerPiece {
        get {
            switch location {
            case .topRightFront: return self.topRightFront
            case .topLeftFront: return self.topLeftFront
            case .topLeftBack: return self.topLeftBack
            case .topRightBack: return self.topRightBack
            case .bottomRightFront: return self.bottomRightFront
            case .bottomLeftFront: return self.bottomLeftFront
            case .bottomLeftBack: return self.bottomLeftBack
            case .bottomRightBack: return self.bottomRightBack
            }
        }
        set {
            switch location {
            case .topRightFront: self.topRightFront = newValue
            case .topLeftFront: self.topLeftFront = newValue
            case .topLeftBack: self.topLeftBack = newValue
            case .topRightBack: self.topRightBack = newValue
            case .bottomRightFront: self.bottomRightFront = newValue
            case .bottomLeftFront: self.bottomLeftFront = newValue
            case .bottomLeftBack: self.bottomLeftBack = newValue
            case .bottomRightBack: self.bottomRightBack = newValue
            }
        }
    }

    mutating func map(_ face: Face, _ f: (CornerLocation, CornerPiece) -> CornerPiece) {
        for location in CornerLocation.locations(in: face) {
            let piece = self[location]
            let newPiece = f(location, piece)

            if newPiece != piece {
                self[location] = newPiece
            }
        }
    }

    public var all: [CornerPiece] {
        return [self.topRightFront, self.topLeftFront, self.topLeftBack, self.topRightBack, self.bottomRightFront, self.bottomLeftFront, self.bottomLeftBack, self.bottomRightBack]
    }
}

public struct Cube {
    public struct Pieces {
        static let numberOfEdges = EdgeLocation.all.count
        static let numberOfCorners = CornerLocation.all.count

        public var edges: EdgePieceCollection
        public var corners: CornerPieceCollection
    }

    public var pieces: Pieces

    public static let unscrambledCube = Cube()

    public init() {
        self.pieces = Pieces(
            edges: EdgePieceCollection(
                topRight: EdgePiece(.topRight),
                topFront: EdgePiece(.topFront),
                topLeft: EdgePiece(.topLeft),
                topBack: EdgePiece(.topBack),
                middleRightFront: EdgePiece(.middleRightFront),
                middleLeftFront: EdgePiece(.middleLeftFront),
                middleLeftBack: EdgePiece(.middleLeftBack),
                middleRightBack: EdgePiece(.middleRightBack),
                bottomRight: EdgePiece(.bottomRight),
                bottomFront: EdgePiece(.bottomFront),
                bottomLeft: EdgePiece(.bottomLeft),
                bottomBack: EdgePiece(.bottomBack)
            ),
            corners: CornerPieceCollection(
                topRightFront: CornerPiece(.topRightFront),
                topLeftFront: CornerPiece(.topLeftFront),
                topLeftBack: CornerPiece(.topLeftBack),
                topRightBack: CornerPiece(.topRightBack),
                bottomRightFront: CornerPiece(.bottomRightFront),
                bottomLeftFront: CornerPiece(.bottomLeftFront),
                bottomLeftBack: CornerPiece(.bottomLeftBack),
                bottomRightBack: CornerPiece(.bottomRightBack)
            )
        )
    }

    public init(applyingToSolvedCube moves: [Move]) {
        var cube = Cube.unscrambledCube

        cube.apply(moves)

        self = cube
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

extension EdgePieceCollection: Equatable {
    public static func ==(lhs: EdgePieceCollection, rhs: EdgePieceCollection) -> Bool {
        return lhs.topRight == rhs.topRight &&
            lhs.topFront == rhs.topFront &&
            lhs.topLeft == rhs.topLeft &&
            lhs.topBack == rhs.topBack &&
            lhs.middleRightFront == rhs.middleRightFront &&
            lhs.middleLeftFront == rhs.middleLeftFront &&
            lhs.middleLeftBack == rhs.middleLeftBack &&
            lhs.middleRightBack == rhs.middleRightBack &&
            lhs.bottomRight == rhs.bottomRight &&
            lhs.bottomFront == rhs.bottomFront &&
            lhs.bottomLeft == rhs.bottomLeft &&
            lhs.bottomBack == rhs.bottomBack
    }
}

extension CornerPieceCollection: Equatable {
    public static func ==(lhs: CornerPieceCollection, rhs: CornerPieceCollection) -> Bool {
    return lhs.topRightFront == rhs.topRightFront &&
        lhs.topLeftFront == rhs.topLeftFront &&
        lhs.topLeftBack == rhs.topLeftBack &&
        lhs.topRightBack == rhs.topRightBack &&
        lhs.bottomRightFront == rhs.bottomRightFront &&
        lhs.bottomLeftFront == rhs.bottomLeftFront &&
        lhs.bottomLeftBack == rhs.bottomLeftBack &&
        lhs.bottomRightBack == rhs.bottomRightBack
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

    fileprivate static let topEdges: [EdgeLocation] = [.topRight, .topFront, .topLeft, .topBack]
    fileprivate static let bottomEdges: [EdgeLocation] = [.bottomFront, .bottomRight, .bottomBack, .bottomLeft]
    fileprivate static let leftEdges: [EdgeLocation] = [.topLeft, .middleLeftFront, .bottomLeft, .middleLeftBack]
    fileprivate static let rightEdges: [EdgeLocation] = [.topRight, .middleRightBack, .bottomRight, .middleRightFront]
    fileprivate static let frontEdges: [EdgeLocation] = [.topFront, .middleRightFront, .bottomFront, .middleLeftFront]
    fileprivate static let backEdges: [EdgeLocation] = [.topBack, .middleLeftBack, .bottomBack, .middleRightBack]

    // Sorted clockwise
    static func locations(in face: Face) -> [EdgeLocation] {
        switch face {
        case .top: return EdgeLocation.topEdges
        case .bottom: return EdgeLocation.bottomEdges
        case .left: return EdgeLocation.leftEdges
        case .right: return EdgeLocation.rightEdges
        case .front: return EdgeLocation.frontEdges
        case .back: return EdgeLocation.backEdges
        }
    }
}

extension CornerLocation {
    static let all: Set<CornerLocation> = [.topRightFront, .topLeftFront, .topLeftBack, .topRightBack, .bottomRightFront, .bottomLeftFront, .bottomLeftBack, .bottomRightBack]

    fileprivate static let topCorners: [CornerLocation] = [.topRightFront, .topLeftFront, .topLeftBack, .topRightBack]
    fileprivate static let bottomCorners: [CornerLocation] = [.bottomLeftFront, .bottomRightFront, .bottomRightBack, .bottomLeftBack]
    fileprivate static let leftCorners: [CornerLocation] = [.topLeftBack, .topLeftFront, .bottomLeftFront, .bottomLeftBack]
    fileprivate static let rightCorners: [CornerLocation] = [.topRightFront, .topRightBack, .bottomRightBack, .bottomRightFront]
    fileprivate static let frontCorners: [CornerLocation] = [.topLeftFront, .topRightFront, .bottomRightFront, .bottomLeftFront]
    fileprivate static let backCorners: [CornerLocation] = [.topRightBack, .topLeftBack, .bottomLeftBack, .bottomRightBack]

    // Sorted clockwise
    static func locations(in face: Face) -> [CornerLocation] {
        switch face {
        case .top: return CornerLocation.topCorners
        case .bottom: return CornerLocation.bottomCorners
        case .left: return CornerLocation.leftCorners
        case .right: return CornerLocation.rightCorners
        case .front: return CornerLocation.frontCorners
        case .back: return CornerLocation.backCorners
        }
    }
}

extension Face {
    func contains(_ edgeLocation: EdgeLocation) -> Bool {
        switch (self, edgeLocation) {
        case (.top, .topRight), (.top, .topFront), (.top, .topLeft), (.top, .topBack): return true
        case (.bottom, .bottomFront), (.bottom, .bottomRight), (.bottom, .bottomBack), (.bottom, .bottomLeft): return true
        case (.left, .topLeft), (.left, .middleLeftFront), (.left, .bottomLeft), (.left, .middleLeftBack): return true
        case (.right, .topRight), (.right, .middleRightBack), (.right, .bottomRight), (.right, .middleRightFront): return true
        case (.front, .topFront), (.front, .middleRightFront), (.front, .bottomFront), (.front, .middleLeftFront): return true
        case (.back, .topBack), (.back, .middleLeftBack), (.back, .bottomBack), (.back, .middleRightBack): return true
        default: return false
        }
    }

    func contains(_ cornerLocation: CornerLocation) -> Bool {
        switch (self, cornerLocation) {
        case (.top, .topRightFront), (.top, .topLeftFront), (.top, .topLeftBack), (.top, .topRightBack): return true
        case (.bottom, .bottomLeftFront), (.bottom, .bottomRightFront), (.bottom, .bottomRightBack), (.bottom, .bottomLeftBack): return true
        case (.left, .topLeftBack), (.left, .topLeftFront), (.left, .bottomLeftFront), (.left, .bottomLeftBack): return true
        case (.right, .topRightFront), (.right, .topRightBack), (.right, .bottomRightBack), (.right, .bottomRightFront): return true
        case (.front, .topLeftFront), (.front, .topRightFront), (.front, .bottomRightFront), (.front, .bottomLeftFront): return true
        case (.back, .topRightBack), (.back, .topLeftBack), (.back, .bottomLeftBack), (.back, .bottomRightBack): return true
        default: return false
        }
    }
}

extension Cube {
    public var numberOfPiecesInCorrectLocation: Int {
        let unscrambled = Cube.unscrambledCube

        var count = 0

        for edgeLocation in EdgeLocation.all {
            if unscrambled.pieces.edges[edgeLocation].location == self.pieces.edges[edgeLocation].location {
                count += 1
            }
        }

        for cornerLocation in CornerLocation.all {
            if unscrambled.pieces.corners[cornerLocation].location == self.pieces.corners[cornerLocation].location {
                count += 1
            }
        }

        return count
    }

    public var numberOfPiecesWithCorrectOrientation: Int {
        var count = 0

        let edges = self.pieces.edges.all
        let corners = self.pieces.corners.all

        for edge in edges where edge.orientation == .correct {
            count += 1
        }

        for corner in corners where corner.orientation == .correct {
            count += 1
        }

        return count
    }

    // The total number of pieces that are in the correct location and orientation
    public var numberOfSolvedPieces: Int {
        var count = 0

        let edges = self.pieces.edges
        let corners = self.pieces.corners

        for edgeLocation in EdgeLocation.all {
            let edge = edges[edgeLocation]
            if edge.orientation == .correct && edge.location == edgeLocation {
                count += 1
            }
        }

        for cornerLocation in CornerLocation.all {
            let corner = corners[cornerLocation]
            if corner.orientation == .correct && corner.location == cornerLocation {
                count += 1
            }
        }

        return count
    }
}

extension Face: CustomStringConvertible {
    public var description: String {
        switch self {
        case .top: return "U"
        case .bottom: return "D"
        case .left: return "L"
        case .right: return "R"
        case .front: return "F"
        case .back: return "B"
        }
    }
}
