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

import Foundation
import XCTest

let key = "REACTIVE_STREAM_TEST_PERFORM_ASSERT_CRASHES_BLOCKS"
let onValue = "YES"

extension XCTest {
    var testCaseName: String {
        String(describing: type(of: self))
    }

    var testName: String {
        // Since on Apple platforms `self.name` has
        // format `-[XCTestCaseSubclassName testMethodName]`,
        // and on other platforms the format is
        // `XCTestCaseSubclassName.testMethodName`
        // we have this workaround in order to unify the names
        name.components(separatedBy: testCaseName)
            .last!
            .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }

    public func assertCrashes(name: String, _ block: () throws -> Void,
        file: StaticString = #filePath, line: UInt = #line) rethrows {
        func removeAll(_ value: String) -> Bool {
            value.hasPrefix(name) || value == "-XCTest"
        }

        let isChild = ProcessInfo.processInfo.environment[key] == onValue

        if isChild {
            try block()
        } else {
            var arguments = ProcessInfo.processInfo.arguments
            let path = arguments[0]
            arguments.removeFirst()
            arguments.removeAll(where: removeAll)
            arguments.insert("\(name).\(testCaseName)/\(testName)", at: 0)
#if os(macOS)
            arguments.insert("-XCTest", at: 0)
#endif

            let process = Process()
            if #available(macOS 10.13, *) {
                process.executableURL = URL(fileURLWithPath: path)
            } else {
                process.launchPath = path
            }
            process.arguments = arguments

            var environment = ProcessInfo.processInfo.environment
            environment[key] = onValue
            process.environment = environment

            func log() {
                print("Parent process invocation:")
                print(ProcessInfo.processInfo.arguments.joined(separator: " "))
                print("Child process invocation:")
                print(([path] + arguments).joined(separator: " "))
            }

            do {
                if #available(macOS 10.13, *) {
                    try process.run()
                } else {
                    process.launch()
                }
                process.waitUntilExit()
                if process.terminationReason != .uncaughtSignal {
                    XCTFail("Child process should have crashed: \(process)", file: file, line: line)
                    log()
                }
            } catch {
                XCTFail("Couldn't start child process for testing crash: \(process) - \(error)",
                    file: file, line: line)
                log()
            }

        }
    }
}
