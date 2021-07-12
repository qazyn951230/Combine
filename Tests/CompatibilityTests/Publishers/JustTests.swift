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

typealias Just1 = ReactiveStream.Just
typealias Just2 = Combine.Just

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class JustTests: XCTestCase {
    func testJustSubscription() throws {
//        let recorder1 = Just1(12).receiveRecorder()
        let recorder2 = Just2(12).receiveRecorder(autoConnect: false)
//        let subscription1 = try XCTUnwrap(recorder1.subscription)
        let subscription2 = try XCTUnwrap(recorder2.subscription)
//        XCTAssertTrue(subscription1 is CustomStringConvertible)
//        XCTAssertTrue(subscription2 is CustomStringConvertible)
        subscription2.cancel()
        subscription2.request(.unlimited)
        print(recorder2.recorders)
    }
}
