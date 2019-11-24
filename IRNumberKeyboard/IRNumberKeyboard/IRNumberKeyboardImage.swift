//
//  IRNumberKeyboardImage.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 26/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit

public enum IRNumberKeyboardImage: CustomStringConvertible {
    case delete
    case dismiss
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
    
    public func image() -> UIImage {
        if let img = IRNumberKeyboardImageGetter.keyboardImage(named: self.description) {
            return img
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
