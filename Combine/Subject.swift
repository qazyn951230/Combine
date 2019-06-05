//
//  Subject.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

// https://developer.apple.com/documentation/combine/subject
public protocol Subject: AnyObject, Publisher {
    // Required
    func send(_ value: Output)

    // Required
    func send(completion: Subscribers.Completion<Self.Failure>)
}
