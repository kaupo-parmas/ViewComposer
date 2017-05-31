//
//  ViewStyle.swift
//  ViewComposer
//
//  Created by Alexander Cyon on 2017-05-30.
//
//

import UIKit

struct ViewStyle: Attributed {
    typealias Attribute = ViewAttribute
    typealias Element = ViewAttribute

    var startIndex: Int = 0
    
    let attributes: [ViewAttribute]
    
    init(_ attributes: [ViewAttribute]) {
        self.attributes = attributes
    }
    
    init(arrayLiteral elements: ViewAttribute...) {
        self.attributes = elements
    }
}

extension Attributed {
    func value<AssociatedValue>(_ stripped: Attribute.Stripped) -> AssociatedValue? {
        return attributes.associatedValue(stripped)
    }
    
    func contains(_ attribute: Attribute.Stripped) -> Bool {
        return stripped.contains(attribute)
    }
}

extension ViewStyle {
    func install<S: Styleable>(on styleable: S) {
        guard let view = styleable as? UIView else { fatalError("not a view") }
        if let control = view as? UIControl {
            control.apply(self)
        }
        
        if let textHolder = view as? TextHolder {
            textHolder.apply(self)
        }
        
        if let imageHolder = view as? ImageHolder {
            imageHolder.apply(self)
        }
        
        if let stackView = view as? UIStackView {
            stackView.apply(self)
        }
        
        if let scrollView = view as? UIScrollView {
            scrollView.apply(self)
        }
        
        if let stateHolder = view as? ControlStateHolder {
            stateHolder.apply(self)
        }
        
        // Shared
        attributes.forEach {
            switch $0 {
            // All UIViews
            case .backgroundColor(let color):
                view.backgroundColor = color
            case .cornerRadius(let radius):
                view.layer.cornerRadius = radius
                view.layer.masksToBounds = radius > 0
            case .verticalHugging(let prio):
                view.setContentHuggingPriority(prio.value, for: .vertical)
            case .verticalCompression(let prio):
                view.setContentCompressionResistancePriority(prio.value, for: .vertical)
            case .horizontalHugging(let prio):
                view.setContentHuggingPriority(prio.value, for: .horizontal)
            case .horizontalCompression(let prio):
                view.setContentCompressionResistancePriority(prio.value, for: .horizontal)
            default:
                break
            }
        }
    }
}


private extension UIControl {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
            case .target(let actor):
                addTarget(actor.target, action: actor.selector, for: actor.event)
            default:
                break
            }
        }
    }
}

private extension TextHolder {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
//            case .font(let font):
//                setFont(font)
            case .textColor(let textColor):
                setTextColor(textColor)
            case .text(let text):
                setText(text)
//            case .l10n(let text):
//                setText(text)
            case .textAlignment(let textAlignment):
                setTextAlignment(textAlignment)
            case .case(let `case`):
                setCase(`case`)
            default:
                break
            }
        }
    }
}

private extension ImageHolder {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
            case .image(let image):
                setImage(image)
//            case .asset(let image):
//                setImage(image)
            default:
                break
            }
        }
    }
}

private extension UIStackView {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
            case .alignment(let alignment):
                self.alignment = alignment
            case .axis(let axis):
                self.axis = axis
            case .spacing(let spacing):
                self.spacing = spacing
            case .distribution(let distribution):
                self.distribution = distribution
            case .margin(let margin):
                layoutMargins = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
                isLayoutMarginsRelativeArrangement = true
            default:
                break
            }
        }
    }
}

private extension UIScrollView {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
            case .isScrollEnabled(let isScrollEnabled):
                self.isScrollEnabled = isScrollEnabled
            default:
                break
            }
        }
    }
}

private extension ControlStateHolder {
    func apply(_ style: ViewStyle) {
        style.attributes.forEach {
            switch $0 {
            case .states(let states):
                setControlStates(states)
            default:
                break
            }
        }
    }
}
