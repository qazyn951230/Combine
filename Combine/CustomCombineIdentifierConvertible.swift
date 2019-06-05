//
//  CustomCombineIdentifierConvertible.swift
//  Combine
//
//  Created by Nan Yang on 2019/6/5.
//  Copyright © 2019 Nan Yang. All rights reserved.
//

public protocol CustomCombineIdentifierConvertible {
    var combineIdentifier: CombineIdentifier { get }
}

public extension CustomCombineIdentifierConvertible {
    var combineIdentifier: CombineIdentifier {
        return CombineIdentifier()
    }
}
