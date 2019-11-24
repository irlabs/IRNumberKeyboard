//
//  IRNumberKeyboardDelegate.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 14/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit


/**
 The `IRNumberKeyboardDelegate` protocol defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional (implemented in an extension)
 */
public protocol IRNumberKeyboardDelegate: class {
    
    /**
     Asks whether the specified text should be inserted.
     
     - Parameter numberKeyboard: The keyboard instance proposing the text insertion.
     - Parameter text:           The proposed text to be inserted.
     
     - Returns: `true` if the text should be inserted or `false` if it should not.
     */
    func numberKeyboardShouldInsert(_ numberKeyboard: IRNumberKeyboard, text: String) -> Bool
    
    /**
     Asks the delegate if the keyboard should process the pressing of the return button.
     
     - Parameter numberKeyboard: The keyboard whose return button was tapped.
     
     - Returns: `true` if the keyboard should implement its default behavior for the return button; otherwise, `false`.
     */
    func numberKeyboardShouldReturn(_ numberKeyboard: IRNumberKeyboard) -> Bool
    
    /**
     Asks the delegate if the keyboard should remove the character just before the cursor.
     
     - Parameter numberKeyboard: The keyboard whose return backwards button was tapped.
     
     - Returns: `true` if the keyboard should implement its default behavior for the delete backward button otherwise, `false`.
     */
    func numberKeyboardShouldDeleteBackward(_ numberKeyboard: IRNumberKeyboard) -> Bool
    
}

public extension IRNumberKeyboardDelegate {
    func numberKeyboardShouldInsert(_ numberKeyboard: IRNumberKeyboard, text: String) -> Bool {
        return true
    }
    func numberKeyboardShouldReturn(_ numberKeyboard: IRNumberKeyboard) -> Bool {
        return false
    }
    func numberKeyboardShouldDeleteBackward(_ numberKeyboard: IRNumberKeyboard) -> Bool {
        return true
    }
}
