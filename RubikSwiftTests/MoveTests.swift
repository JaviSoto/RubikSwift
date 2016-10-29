//
//  MoveTests.swift
//  RubikSwift
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import XCTest
@testable import RubikSwift

class MoveTests: XCTestCase {
    func testCornerRotationAddition() {
        let correct = CornerPiece.Orientation.correct
        let clockwise = CornerPiece.Orientation.rotatedClockwise
        let counterClockwise = CornerPiece.Orientation.rotatedCounterClockwise

        XCTAssertEqual(correct + correct, correct)

        XCTAssertEqual(correct + clockwise, clockwise)
        XCTAssertEqual(clockwise + correct, clockwise)

        XCTAssertEqual(correct + counterClockwise, counterClockwise)
        XCTAssertEqual(counterClockwise + correct, counterClockwise)

        XCTAssertEqual(clockwise + counterClockwise, correct)
        XCTAssertEqual(counterClockwise + clockwise, correct)

        XCTAssertEqual(clockwise + clockwise, counterClockwise)
        XCTAssertEqual(counterClockwise + counterClockwise, clockwise)
    }

    func assertMovesCancelOut(in face: Face, magnitudes: [Move.Magnitude]) {
        let initialCube = Cube.unscrambledCube
        var cube = initialCube

        let moves = magnitudes.map { Move(face: face, magnitude: $0) }

        cube.apply(moves)

        XCTAssertEqual(cube, initialCube)
    }

    func testOppositeMovesTop() {
        assertMovesCancelOut(in: .top, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func testOppositeMovesBottom() {
        assertMovesCancelOut(in: .bottom, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func testOppositeMovesLeft() {
        assertMovesCancelOut(in: .left, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func testOppositeMovesRight() {
        assertMovesCancelOut(in: .right, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func testOppositeMovesFront() {
        assertMovesCancelOut(in: .front, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func testOppositeMovesBack() {
        assertMovesCancelOut(in: .back, magnitudes: [.clockwiseQuarterTurn, .counterClockwiseQuarterTurn])
    }

    func test2HalfTurnsTop() {
        assertMovesCancelOut(in: .top, magnitudes: [.halfTurn, .halfTurn])
    }

    func test2HalfTurnsBottom() {
        assertMovesCancelOut(in: .bottom, magnitudes: [.halfTurn, .halfTurn])
    }

    func test2HalfTurnsLeft() {
        assertMovesCancelOut(in: .left, magnitudes: [.halfTurn, .halfTurn])
    }

    func test2HalfTurnsRight() {
        assertMovesCancelOut(in: .right, magnitudes: [.halfTurn, .halfTurn])
    }

    func test2HalfTurnsFront() {
        assertMovesCancelOut(in: .front, magnitudes: [.halfTurn, .halfTurn])
    }

    func test2HalfTurnsBack() {
        assertMovesCancelOut(in: .back, magnitudes: [.halfTurn, .halfTurn])
    }

    func testRandomMovesAndTheirOpposites() {
        let initialCube = Cube.unscrambledCube
        var cube = initialCube

        let numberOfMoves = 250
        let randomMoves: [Move] = (1..<numberOfMoves)
            .map { _ in return Move.random }

        let oppositeMoves = randomMoves.opposite

        cube.apply(randomMoves + oppositeMoves)

        XCTAssertEqual(cube, initialCube)
    }

    func testTAlgorithm() {
        let initialCube = Cube.unscrambledCube

        let afterAlgorithm = initialCube.applying(Move.moves("R U R' U' R' F R2 U' R' U' R U R' F'")!)

        XCTAssertFalse(afterAlgorithm.pieces.corners.all.contains { $0.orientation != .correct })
    }

    func testCornerPermutation() {
        let initialCube = Cube.unscrambledCube

        let afterAlgorithm = initialCube.applying(Move.moves("F U")!)

        XCTAssertEqual(afterAlgorithm.pieces.corners.topRightFront.orientation, .correct)
    }

    func testOLL1() {
        let initialCube = Cube.unscrambledCube

        let afterAlgorithm = initialCube.applying(Move.moves("F R U R' U' F'")!.opposite)

        XCTAssertEqual(afterAlgorithm.pieces.corners.topRightFront.orientation, .correct)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topLeftFront.orientation, .rotatedCounterClockwise)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topLeftBack.orientation, .rotatedClockwise)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topRightBack.orientation, .correct)
    }

    func testOLL2() {
        let initialCube = Cube.unscrambledCube

        let afterAlgorithm = initialCube.applying(Move.moves("R' F R2 B' R2 F' R2 B R'")!.opposite)

        XCTAssertEqual(afterAlgorithm.pieces.corners.topRightFront.orientation, .rotatedClockwise)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topLeftFront.orientation, .rotatedClockwise)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topLeftBack.orientation, .rotatedCounterClockwise)
        XCTAssertEqual(afterAlgorithm.pieces.corners.topRightBack.orientation, .rotatedCounterClockwise)
    }
}
