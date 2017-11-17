//
//  ReactiveUtil.swift
//  MonkeyCounter
//
//  Created by Colin Eberhardt on 10/05/2015.
//  Copyright (c) 2015 Colin Eberhardt. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ReactiveCocoa
import ReactiveSwift

// must be unique
struct AssociationKey {
    static var hidden: UInt8 = 1
    static var alpha: UInt8 = 2
    static var lbl_text: UInt8 = 3
    static var fld_text: UInt8 = 4
    static var enabled: UInt8 = 5
    static var editable: UInt8 = 6
    static var typing: UInt8 = 7
}

// lazily creates a gettable associated property via the given factory
func lazyAssociatedProperty<T: AnyObject>(host: AnyObject, key: UnsafeRawPointer, factory: ()->T) -> T {
    return objc_getAssociatedObject(host, key) as? T ?? {
        let associatedProperty = factory()
        objc_setAssociatedObject(host, key, associatedProperty, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return associatedProperty
        }()
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafeRawPointer, setter: @escaping (T) -> (), getter: () -> T) -> MutableProperty<T> {
    return lazyAssociatedProperty(host: host, key: key) {
        let property = MutableProperty<T>(getter())
        property.producer
            .observeForUI()
            .startWithValues{
                newValue in
                setter(newValue)
        }
        
        return property
    }
}

// MARK :- UIView
extension UIView {
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(host: self, key: &AssociationKey.alpha, setter: { self.alpha = $0 }, getter: { self.alpha  })
    }
    
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(host: self, key: &AssociationKey.hidden, setter: { self.isHidden = $0 }, getter: { self.isHidden  })
    }
}

// MARK :- UILabel
extension UILabel {
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(host: self, key: &AssociationKey.lbl_text, setter: { self.text = $0 }, getter: { self.text ?? "" })
    }
}

// MARK :- UITextField
extension UITextField {
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(host: self, key: &AssociationKey.fld_text) {
            
            self.addTarget(self, action: #selector(self.changed), for: UIControlEvents.editingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            property.producer
                .observeForUI()
                .startWithValues {
                    newValue in
                    self.text = newValue
            }
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}

// MARK :- JSQMessagesViewController
extension JSQMessagesViewController {
    // Show/hide a typing indicator
    public var rac_showTypingIndicator: MutableProperty<Bool> {
        return lazyMutableProperty(host: self, key: &AssociationKey.typing, setter: { self.showTypingIndicator = $0 }, getter: { self.showTypingIndicator })
    }
    
    // Disable/enable input toolbar accessory view
    public var rac_accessoryEnabled: MutableProperty<Bool> {
        return lazyMutableProperty(host: self, key: &AssociationKey.enabled, setter: { self.inputToolbar.contentView.leftBarButtonItem.isEnabled = $0 }, getter: { self.inputToolbar.contentView.leftBarButtonItem.isEnabled })
    }
    
    // Disable/enable input toolbar text view
    public var rac_textViewEnabled: MutableProperty<Bool> {
        return lazyMutableProperty(host: self, key: &AssociationKey.editable, setter: { self.inputToolbar.contentView.textView.isEditable = $0 }, getter: { self.inputToolbar.contentView.textView.isEditable })
    }
}
