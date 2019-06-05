//
//  CombineTests.swift
//  CombineTests
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

import XCTest
@testable import Combine

class CombineTests: XCTestCase {
    func testJust() {
        let foo = Publishers.Just(123)
        let sink = Subscribers.Sink<Publishers.Just<Int>> { v in
            XCTAssertEqual(v, 123)
        }
        foo.subscribe(sink)
    }

    func testMap() {
        let foo = Publishers.Just(123)
            .map { "\($0)" }
        let sink = Subscribers.Sink<Publishers.Map<Publishers.Just<Int>, String>>{ v in
            XCTAssertEqual(v, "123")
        }
        foo.subscribe(sink)
    }

    func testMapMapMap() {
        let foo = Publishers.Just(123)
            .map { "\($0)" }
            .map { $0 + "456" }
            .map { Int($0) ?? 123456 }
        let sink = Subscribers.Sink<Publishers.Map<Publishers.Map<Publishers.Map<Publishers.Just<Int>, String>, String>, Int>> { v in
            XCTAssertEqual(v, 123456)
        }
        foo.subscribe(sink)
    }

    func testAnyJust() {
        let foo = Publishers.Just(123)
            .eraseToAnyPublisher()
        let sink = Subscribers.Sink<AnyPublisher<Int, Never>> { v in
            XCTAssertEqual(v, 123)
        }
        foo.subscribe(sink)
    }

    func testAnyMap() {
        let foo = Publishers.Just(123)
            .map { "\($0)" }
            .eraseToAnyPublisher()
        let sink = Subscribers.Sink<AnyPublisher<String, Never>> { v in
            XCTAssertEqual(v, "123")
        }
        foo.subscribe(sink)
    }
}
