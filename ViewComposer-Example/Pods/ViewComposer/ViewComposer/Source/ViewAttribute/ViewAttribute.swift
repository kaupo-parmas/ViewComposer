//
//  ViewAttribute.swift
//  Pods
//
//  Created by Alexander Cyon on 2017-05-29.
//
//

import Foundation

extension ViewAttribute: AutoAssociatedValueStrippable {}
enum ViewAttribute {
    case custom(AnyAttributed)
    
    // View
    case backgroundColor(UIColor)
    case cornerRadius(CGFloat) /* might be overridden by: */; case radius(Radius)
    case verticalHugging(LayoutPriority)
    case verticalCompression(LayoutPriority)
    case horizontalHugging(LayoutPriority)
    case horizontalCompression(LayoutPriority)
    case height(CGFloat)
    case width(CGFloat)
    
    // TextHolder
    case text(String)
//    case l10n(L10n)
//    case font(Font)
    case textColor(UIColor)
    case `case`(Case)
    case textAlignment(NSTextAlignment)
    
    // ImageHolder
    case image(UIImage)
//    case asset(Asset)
    
    // UIScrollView
    case isScrollEnabled(Bool)
    
    // ControlState
    case states([ControlState])
    
    // UIControl
    case target(Actor)
    
    // UIStackView
    case axis(UILayoutConstraintAxis)
    case distribution(UIStackViewDistribution)
    case alignment(UIStackViewAlignment)
    case spacing(CGFloat)
    case margin(CGFloat)
    case arrangedSubviews([UIView])
}

extension Array where Element == ViewAttribute {
    func merge(slave: [ViewAttribute]) -> [ViewAttribute] {
        return ViewStyle(self).merge(slave: ViewStyle(slave)).attributes
    }
    
    func merge(master: [ViewAttribute]) -> [ViewAttribute] {
        return ViewStyle(self).merge(master: ViewStyle(master)).attributes
    }
}

