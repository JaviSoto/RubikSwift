//
//  Cube.swift
//  RubikSwiftTests
//
//  Created by Javier Soto on 10/28/16.
//  Copyright © 2016 Javier Soto. All rights reserved.
//

import XCTest
@testable import RubikSwift

class CubeTests: XCTestCase {
    func testInitialPositionEquatable() {
        let cube1 = Cube.unscrambledCube
        let cube2 = Cube.unscrambledCube

        XCTAssertEqual(cube1, cube2)
    }

    func testInitialPositionForAllPieces() {
        let cube = Cube.unscrambledCube

        for edgeLocation in EdgeLocation.all {
            let edge = cube.pieces.edges[edgeLocation]

            XCTAssertEqual(edge.location, edgeLocation)
            XCTAssertEqual(edge.orientation, .correct)
        }

        for cornerLocation in CornerLocation.all {
            let corner = cube.pieces.corners[cornerLocation]

            XCTAssertEqual(corner.location, cornerLocation)
            XCTAssertEqual(corner.orientation, .correct)
        }
    }
}
