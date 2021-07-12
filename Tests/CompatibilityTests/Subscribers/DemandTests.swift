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
import Combine
@testable import ReactiveStream

typealias Demand1 = ReactiveStream.Subscribers.Demand
typealias Demand2 = Combine.Subscribers.Demand

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class DemandTests: XCTestCase {
    func testCreation() {
        XCTAssertCrashes {
            _ = Demand1.max(-1)
        }
        XCTAssertCrashes {
            _ = Demand2.max(-1)
        }
    }

    func testDescription() {
        XCTAssertEqual(Demand1.none.description, Demand2.none.description)
        XCTAssertEqual(Demand1.unlimited.description, Demand2.unlimited.description)
        XCTAssertEqual(Demand1.max(123).description, Demand2.max(123).description)
        XCTAssertEqual(Demand1.max(.max).description, Demand2.max(.max).description)
    }
}
