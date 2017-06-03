//
//  Attributed.swift
//  ViewComposer
//
//  Created by Alexander Cyon on 2017-05-31.
//
//

import Foundation

public protocol BaseAttributed {
    func install(on styleable: Any)
}

public protocol Attributed: Collection, ExpressibleByArrayLiteral, BaseAttributed {
    associatedtype Attribute: AssociatedValueStrippable, AssociatedValueEnumExtractor
    var attributes: [Attribute] { get }
    init(_ attributes: [Attribute])
    associatedtype Element = Attribute
    
    func merge(slave: Self) -> Self
    func merge(master: Self) -> Self
    func merge(slave: [Attribute]) -> Self
    func merge(slave: Attribute) -> Self
    func merge(master: [Attribute]) -> Self
    func merge(master: Attribute) -> Self
    
    var startIndex: Int { get }
}

public extension Attributed {
    typealias Index = Int
    typealias Iterator = IndexingIterator<Self>
    typealias Indices = DefaultIndices<Self>
    
    public var endIndex: Int { return count }
    public var count: Int { return attributes.count }
    public var isEmpty: Bool { return attributes.isEmpty }
    
    public subscript (position: Int) -> Self.Attribute { return attributes[position] }
    
    public func index(after index: Int) -> Int {
        guard index < endIndex else { return endIndex }
        return index + 1
    }
    
    public func index(before index: Int) -> Int {
        guard index > startIndex else { return startIndex }
        return index - 1
    }
}

public extension Attributed {
    typealias Stripped = Attribute.Stripped
    var stripped: [Stripped] { return attributes.map { $0.stripped } }
}

public extension Attributed {
    func value<AssociatedValue>(_ stripped: Attribute.Stripped) -> AssociatedValue? {
        return attributes.associatedValue(stripped)
    }

    func contains(_ attribute: Attribute.Stripped) -> Bool {
        return stripped.contains(attribute)
    }
}

public protocol CustomAttributeMerger {
    associatedtype CustomAttribute: Attributed
    associatedtype Style: Attributed
    func customMerge(slave: Style, into master: Style) -> Style
}

extension CustomAttributeMerger where Self: Attributed, Self.Attribute == ViewAttribute {
    public func customMerge(slave: ViewStyle, into master: ViewStyle) -> ViewStyle {
        let merged = master.merge(slave: slave)
        if let customStyle: CustomAttribute = master.value(.custom), let slaveCustomStyle: CustomAttribute = slave.value(.custom) {
            let customMerge = customStyle.merge(slave: slaveCustomStyle)
            return ViewStyle([.custom(customMerge)]).merge(slave: merged)
        } else {
            return merged
        }
    }
}

public extension Optional where Wrapped: Attributed {
    func merge(slave: Wrapped) -> Wrapped {
        guard let `self` = self else { return slave }
        return self.merge(slave: slave)
    }
    
    func merge(master: Wrapped) -> Wrapped {
        guard let `self` = self else { return master }
        return self.merge(master: master)
    }
}

public extension Attributed {
    
    func merge(slave: Self) -> Self {
        let unionSet = Set(stripped).union(Set(slave.stripped))
        let unionAttributes = (attributes + slave.attributes).filter(stripped: Array(unionSet))
        return Self(unionAttributes)
    }
    
    func merge(master: Self) -> Self {
        return master.merge(slave: self)
    }
    
    func merge(slave: [Attribute]) -> Self {
        return merge(slave: Self(slave))
    }
    
    func merge(slave: Attribute) -> Self {
        return merge(slave: Self([slave]))
    }
    
    func merge(master: [Attribute]) -> Self {
        return Self(master).merge(slave: self)
    }
    
    func merge(master: Attribute) -> Self {
        return Self([master]).merge(slave: self)
    }
}

public extension Array where Element: AssociatedValueStrippable {
    func filter(stripped: [Element.Stripped]) -> [Element] {
        var filtered = [Element]()
        for attribute in self {
            guard stripped.contains(attribute.stripped) && !(filtered.map { $0.stripped }.contains(attribute.stripped)) else { continue }
            filtered.append(attribute)
        }
        return filtered
    }
}