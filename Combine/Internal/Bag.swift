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

struct BagItem<Item>: Hashable where Item: CustomCombineIdentifierConvertible {
    @inline(__always)
    var identifier: CombineIdentifier {
        return item.combineIdentifier
    }
    let item: Item

    init(_ item: Item) {
        self.item = item
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func ==(lhs: BagItem, rhs: BagItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

final class Bag<Item>: SetAlgebra where Item: CustomCombineIdentifierConvertible {
    typealias Element = Item
    private(set) var content: Set<BagItem<Item>>

    init() {
        content = Set()
    }

    init(arrayLiteral elements: Element...) {
        content = Set(elements.map(BagItem.init))
    }

    init(content: Set<BagItem<Item>>) {
        self.content = content
    }

    func contains(_ member: Item) -> Bool {
        return content.contains(BagItem(member))
    }

    func union(_ other: Bag<Item>) -> Bag<Item> {
        return Bag(content: content.union(other.content))
    }

    func intersection(_ other: Bag<Item>) -> Bag<Item> {
        return Bag(content: content.intersection(other.content))
    }

    func symmetricDifference(_ other: Bag<Item>) -> Bag<Item> {
        return Bag(content: content.symmetricDifference(other.content))
    }

    func insert(_ newMember: Item) -> (inserted: Bool, memberAfterInsert: Item) {
        let (a, b) = content.insert(BagItem(newMember))
        return (a, b.item)
    }

    func remove(_ member: Item) -> Item? {
        return content.remove(BagItem(member))?.item
    }

    func update(with newMember: Item) -> Item? {
        return content.update(with: BagItem(newMember))?.item
    }

    func formUnion(_ other: Bag<Item>) {
        content.formUnion(other.content)
    }

    func formIntersection(_ other: Bag<Item>) {
        content.formIntersection(other.content)
    }

    func formSymmetricDifference(_ other: Bag<Item>) {
        content.formSymmetricDifference(other.content)
    }

    func removeAll(keepingCapacity keepCapacity: Bool = false) {
        content.removeAll(keepingCapacity: keepCapacity)
    }

    @inlinable func forEach(_ body: (Element) throws -> Void) rethrows {
        try content.forEach { e in
            try body(e.item)
        }
    }

    static func ==(lhs: Bag<Item>, rhs: Bag<Item>) -> Bool {
        return lhs.content == rhs.content
    }
}

extension Bag: Cancellable where Item: Subscription {
    func cancel() {
        let set = content
        content.removeAll(keepingCapacity: false)
        if set.isEmpty {
            return
        }
        set.forEach { item in
            item.item.cancel()
        }
    }
}
