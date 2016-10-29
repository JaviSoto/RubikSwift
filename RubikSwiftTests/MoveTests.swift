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

        let oppositeMoves = randomMoves.reversed().map { $0.opposite }

        cube.apply(randomMoves + oppositeMoves)

        XCTAssertEqual(cube, initialCube)
    }
}
