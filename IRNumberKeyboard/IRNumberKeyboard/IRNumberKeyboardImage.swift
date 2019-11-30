//
//  IRNumberKeyboardImage.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 26/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit

/**
    Helper struct make the Special Key Keyboard Images publicly available.
 
    Usage:
 
        let img = IRNumberKeyboardImage.delete.image()
 */
public enum IRNumberKeyboardImage: CustomStringConvertible {
    /// The backspace button image
    case delete
    /// An image of a keyboard with a down arrow to indicate the dismising of the keyboard
    case dismiss
    /// A special arithmetic symbol to invert the sign of the number.
    case plusMinusSign
    
    
    public var description: String {
        switch self {
        case .delete:
            return "delete"
        case .dismiss:
            return "dismiss"
        case .plusMinusSign:
            return "plusMinusSign"
        }
    }
    
    /**
     Returns the image of this key.
     
     To be used in the configuration of the special key.
    */
    public func image() -> UIImage {
        if let img = IRNumberKeyboardImageGetter.keyboardImage(named: self.description) {
            return img.withRenderingMode(.alwaysTemplate)
        }
        return UIImage()
    }
}

fileprivate class IRNumberKeyboardImageGetter {

    class func keyboardImage(named: String) -> UIImage? {
        let bundle = Bundle(for: self)
        return UIImage.init(named: named, in: bundle, compatibleWith: nil)
    }
}
