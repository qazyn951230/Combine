//
//  Concatenate.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

//private final class ConcatenateConnection<Prefix, Suffix, Downstream>:
//    Connection<Downstream> where Downstream: Subscriber, Prefix : Publisher, Suffix : Publisher,
//    Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output, Downstream.Input == Prefix.Output {
//    let prefix: Prefix
//    let suffix: Suffix
//    var _prefixSink: Subscribers.Sink<Prefix>?
//    var _suffixSink: Subscribers.Sink<Suffix>?
//    var prefixFinished = false
//    var suffixFinished = false
//
//    init(_ prefix: Prefix, _ suffix: Suffix, _ downstream: Downstream) {
//        self.prefix = prefix
//        self.suffix = suffix
//        super.init(downstream)
//    }
//
//    override func request(_ demand: Subscribers.Demand) {
//        if stop {
//            return
//        }
//        if !prefixFinished {
//            let prefixSink = _prefixSink ?? Subscribers.Sink(
//        } else if !suffixFinished {
//
//        } else {
//            forwardFinished()
//        }
//    }
//}

public extension Publishers {
    struct Concatenate<Prefix, Suffix>: Publisher where Prefix : Publisher, Suffix : Publisher,
        Prefix.Failure == Suffix.Failure, Prefix.Output == Suffix.Output {
        public typealias Failure = Suffix.Failure
        public typealias Output = Suffix.Output

        public let prefix: Prefix
        public let suffix: Suffix

        public init(prefix: Prefix, suffix: Suffix) {
            self.prefix = prefix
            self.suffix = suffix
        }

        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
//            let connection = ConcatenateConnection(prefix, suffix, subscriber)
//            subscriber.receive(subscription: connection)
        }
    }
}
