// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
