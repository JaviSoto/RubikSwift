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
        let cube1 = Cube()
        let cube2 = Cube()

        XCTAssertEqual(cube1, cube2)
    }
}
