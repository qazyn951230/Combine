//
//  Sequence.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

private final class SequenceConnection<Elements, Downstream>:
    Connection<Downstream> where Downstream: Subscriber, Elements : Swift.Sequence, Downstream.Input == Elements.Element {
    let input: Elements
    var _iterator: Elements.Iterator?

    init(_ input: Elements, _ downstream: Downstream) {
        self.input = input
        super.init(downstream)
    }

    override func request(_ demand: Subscribers.Demand) {
        if stop {
            return
        }
        var breaked = false
        var iterator = _iterator ?? input.makeIterator()
        _iterator = iterator
        switch demand {
        case let .max(count):
            var index = 0
            while let next = iterator.next(), index < count {
                let ask = forward(next)
                if ask.none {
                    breaked = true
                    break
                }
                index += 1
            }
        case .unlimited:
            while let next = iterator.next() {
                let ask = forward(next)
                if ask.none {
                    breaked = true
                    break
                }
            }
        }
        if iterator.next() == nil || breaked {
            forwardFinished()
        }
    }

    override func cancel() {
        super.cancel()
        _iterator = nil
    }
}

public extension Publishers {
    struct Sequence<Elements, Failure>: Publisher where Elements : Swift.Sequence, Failure : Error {
        public typealias Output = Elements.Element

        public let sequence: Elements

        public init(sequence: Elements) {
            self.sequence  = sequence
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let connection = SequenceConnection(sequence, subscriber)
            subscriber.receive(subscription: connection)
        }
    }
}
