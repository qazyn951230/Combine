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

/// A type-erasing cancellable object that executes a provided closure when canceled.
/// - seealso: [The Combine Library Reference]
///     (https://developer.apple.com/documentation/combine/anycancellable)
///
/// Subscriber implementations can use this type to provide a “cancellation token” that
///     makes it possible for a caller to cancel a publisher,
///     but not to use the `Subscription` object to request items.
public final class AnyCancellable: Cancellable {
    private var _cancel: (() -> Void)?

    /// Initializes the cancellable object with the given cancel-time closure.
    ///
    /// - Parameter cancel: A closure that the `cancel()` method executes.
    public init(_ cancel: @escaping () -> Void) {
        _cancel = cancel
    }

    // TODO: Is it a `convenience` initializer?
    public convenience init<C>(_ canceller: C) where C: Cancellable {
        self.init {
            canceller.cancel()
        }
    }

    /// Cancel the activity.
    public final func cancel() {
        let method = _cancel
        _cancel = nil
        method?()
    }
}
