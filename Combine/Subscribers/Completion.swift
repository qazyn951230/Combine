//
//  Completion.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public extension Subscribers {
    enum Completion<Failure> where Failure : Error {
        case failure(Failure)
        case finished
    }
}
