//
//  Deprecations.swift
//  Pods
//
//  Created by Petr Sima on 04/01/2017.
//
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

private struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var text: UInt8 = 3
    static var image: UInt8 = 4
    static var enabled: UInt8 = 5
    static var progress: UInt8 = 6
    static var selected: UInt8 = 7
    static var title: UInt8 = 8
    static var textColor: UInt8 = 9
    static var borderWidth: UInt8 = 10
    static var borderColor: UInt8 = 11
    static var backgroundColor: UInt8 = 12
    static var tintColor: UInt8 = 13
    static var attributedText: UInt8 = 14
    static var on: UInt8 = 15
    static var animating: UInt8 = 16
    static var textElseHidden: UInt8 = 16
    static var imageElseHidden: UInt8 = 17
}

extension UIView {
    @available(*, deprecated, message: "Use native reactive.alpha")
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.alpha, { [unowned self] in self.alpha = $0 }, { [unowned self] in self.alpha })
    }
    
    @available(*, deprecated, message: "Use native reactive.isHidden")
    public var rac_hidden: DynamicProperty<Bool> {
        return lazyAssociatedProperty(self, &AssociationKey.hidden) { [unowned self] in DynamicProperty(object: self, keyPath: "hidden") }
    }
    @available(*, deprecated, renamed: "reactive.tintColor")
    public var rac_tintColor: MutableProperty<UIColor?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.tintColor, { [unowned self] in self.tintColor = $0 }, { [unowned self] in self.tintColor })
    }
    @available(*, deprecated, renamed: "reactive.backgroundColor")
    public var rac_backgroundColor: MutableProperty<UIColor?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.backgroundColor, { [unowned self] in self.backgroundColor = $0 }, { [unowned self] in self.backgroundColor })
    }
}

extension CALayer {
    public var rac_borderWidth: MutableProperty<CGFloat> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.borderWidth, { [unowned self] in self.borderWidth = $0 }, { [unowned self] in self.borderWidth })
    }
    public var rac_borderColor: MutableProperty<CGColor?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.borderColor, { [unowned self] in self.borderColor = $0 }, { [unowned self] in self.borderColor })
    }
}

extension UILabel {
    @available(*, deprecated, renamed: "reactive.textColor")
    public var rac_textColor: MutableProperty<UIColor?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.textColor, { [unowned self] in self.textColor = $0 }, { [unowned self] in self.textColor })
    }
    
    @available(*, deprecated, renamed: "reactive.attributedText")
    public var rac_attributedText: MutableProperty<NSAttributedString?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.attributedText, { [unowned self] in self.attributedText = $0 }, { [unowned self] in self.attributedText })
    }
}

extension UIProgressView {
    @available(*, deprecated, renamed: "reactive.progress")
    public var rac_progress: MutableProperty<Float> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.progress, { [unowned self] in self.progress = $0 }, { [unowned self] in self.progress })
    }
}

extension UIActivityIndicatorView {
    @available(*, deprecated, renamed: "reactive.isAnimating")
    public var rac_animating: MutableProperty<Bool> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.animating, { [unowned self] in $0 ? self.startAnimating() : self.stopAnimating() }, { [unowned self] in self.isAnimating })
    }
}

extension UITextView {
    @available(*, deprecated, message: "Use native reactive.text, textValues or continuousTextValues")
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, &AssociationKey.text) { [unowned self] in
            NotificationCenter.default.reactive.notifications(forName: .UITextViewTextDidChange, object: self)
                .take(during: self.reactive.lifetime)
                .observeValues { [unowned self] _ in
                    self.rac_text.value = self.text ?? ""
            }
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer.startWithValues { [unowned self] newValue in
                self.text = newValue
            }
            return property
        }
    }
}

extension UINavigationItem {
    @available(*, deprecated, renamed: "reactive.title")
    public var rac_title: MutableProperty<String?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.text, { [unowned self] in self.title = $0 }, { [unowned self] in self.title })
    }
}

//MARK: Controls

extension UIButton {
    @available(*, deprecated, renamed: "reactive.title")
    public var rac_title: MutableProperty<String?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.text, { [unowned self] in self.setTitle($0, for: .normal) }, { [unowned self] in self.titleLabel?.text })
    }
}

extension UISwitch {
    @available(*, deprecated, renamed: "reactive.isOn")
    public var rac_on: MutableProperty<Bool> {
        return lazyAssociatedProperty(self, &AssociationKey.on) {
            
            self.addTarget(self, action: #selector(UISwitch.changed), for: UIControlEvents.valueChanged)
            
            let property = MutableProperty<Bool>(self.isOn)
            property.producer.startWithValues { [unowned self] newValue in
                self.isOn = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_on.value = self.isOn
    }
}

extension UISegmentedControl {
    @available(*, deprecated, message: "Use reactive.selectedSegmentIndex or reactive.selectedSegmentIndexes")
    public var rac_selectedIndex: MutableProperty<Int> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.selected, { [unowned self] in self.selectedSegmentIndex = $0 }, { [unowned self] in self.selectedSegmentIndex })
    }
}

extension UITextField {
    @available(*, deprecated, message: "Use native reactive.text, textValues or continuousTextValues")
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, &AssociationKey.text) {
            
            self.addTarget(self, action: #selector(UITextField.changed), for: UIControlEvents.editingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer.startWithValues { [unowned self] newValue in
                self.text = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
    
    @available(*, deprecated, renamed: "reactive.textColor")
    public var rac_textColor: MutableProperty<UIColor?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.textColor, { [unowned self] in self.textColor = $0 }, { [unowned self] in self.textColor })
    }
    
    @available(*, deprecated, renamed: "reactive.containsValidEmail")
    public var rac_validEmail: SignalProducer<Bool, NoError> {
        return self.rac_text.producer.map {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: $0)
        }
    }
}

//MARK: Enablable

public protocol Enablable: class {
    var enabled: Bool { get set }
}

extension UIControl: Enablable { }
extension UIBarButtonItem: Enablable { }
extension Enablable {
    @available(*, deprecated, renamed: "reactive.isEnabled")
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.enabled, { [unowned self] in self.enabled = $0 }, { [unowned self] in self.enabled })
    }
}

//MARK: Selectable

public protocol Selectable: class {
    var selected: Bool { get set }
}
extension UIControl: Selectable { }
extension UITableViewCell: Selectable { }
extension UICollectionViewCell: Selectable { }
extension Selectable {
    @available(*, deprecated, renamed: "reactive.isSelected")
    public var rac_selected: MutableProperty<Bool> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.selected, { [unowned self] in self.selected = $0 }, { [unowned self] in self.selected })
    }
}

private func ensureMainThread(block: @escaping (Void) -> Void) {
    if Thread.current.isMainThread {
        block()
    }
    else {
        DispatchQueue.main.async {
            block()
        }
    }
}

func lazyMutablePropertyUiKit<T>(_ host: AnyObject, _ key: UnsafeRawPointer, _ setter: @escaping (T) -> (), _ getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host, key) {
        let property = MutableProperty<T>(getter())
        property.producer.startWithValues { x in ensureMainThread { setter(x) } }
        return property
    }
}

public protocol TextContainingView: class { // dont want to name this TextContainer because it might clash with swift3 version of NSTextContainer
    var text: String? { get set }
}

extension UILabel: TextContainingView { }
//extension UITextView: TextContainingView { } //UITextView's .text is a String! not String?, so this doesnt work. But it might start working with swift3's changes to ImplicitlyUnwrappedOptional so lets keep this around.
extension UITextField: TextContainingView { }

public extension TextContainingView {
    @available(*, deprecated, renamed: "reactive.text")
    public var rac_text: MutableProperty<String> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.text, { [unowned self] in self.text = $0 }, { [unowned self] in self.text ?? "" })
    }
}
//this wont be migrated because noone uses it
public extension TextContainingView {
    // only call this once per view
    public func rac_textElseHideView(view: UIView) -> MutableProperty<String?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.textElseHidden, { [unowned self, weak view] in
            self.text = $0
            if let _ = $0 {
                view?.isHidden = false
            } else {
                view?.isHidden = true
            }
            }, { [unowned self] in self.text })
    }
}

public extension TextContainingView where Self: UIView {
    public var rac_textElseHidden: MutableProperty<String?> {
        return rac_textElseHideView(view: self)
    }
}

public protocol ImageContainer: class {
    var image: UIImage? { get set }
}

extension UIImageView: ImageContainer { }

public extension ImageContainer {
    @available(*, deprecated, renamed: "reactive.image")
    public var rac_image: MutableProperty<UIImage?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.image, { [unowned self] in self.image = $0 }, { [unowned self] in self.image })
    }
}
//this wont be migrated because noone uses it
public extension ImageContainer {
    // only call this once per view
    public func rac_imageElseHideView(view: UIView) -> MutableProperty<UIImage?> {
        return lazyMutablePropertyUiKit(self, &AssociationKey.textElseHidden, { [unowned self, weak view] in
            self.image = $0
            if let _ = $0 {
                view?.isHidden = false
            } else {
                view?.isHidden = true
            }
            }, { [unowned self] in self.image })
    }
}

public extension ImageContainer where Self: UIView {
    public var rac_imageElseHidden: MutableProperty<UIImage?> {
        return rac_imageElseHideView(view: self)
    }
}
