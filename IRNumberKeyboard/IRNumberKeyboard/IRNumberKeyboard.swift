//
//  IRNumberKeyboard.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 13/11/2019.
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
     
     - Returns:    `true` if the text should be inserted or `false` if it should not.
    */
    func numberKeyboardShouldInsert(numberKeyboard: IRNumberKeyboard, text: String) -> Bool
    
    /**
     Asks the delegate if the keyboard should process the pressing of the return button.
     
     - Parameter numberKeyboard: The keyboard whose return button was pressed.
     
     - Returns:    `true` if the keyboard should implement its default behavior for the return button; otherwise, `false`.
     */
    func numberKeyboardShouldReturn(numberKeyboard: IRNumberKeyboard) -> Bool

    /**
     Asks the delegate if the keyboard should remove the character just before the cursor.
     
     - Parameter numberKeyboard: The keyboard whose return backwards button was pressed.
     
     - Returns:    `true` if the keyboard should implement its default behavior for the delete backward button; otherwise, `false`.
     */
    func numberKeyboardShouldDeleteBackward(numberKeyboard: IRNumberKeyboard) -> Bool

}

extension IRNumberKeyboardDelegate {
    func numberKeyboardShouldInsert(text: String) -> Bool { return true }
    func numberKeyboardShouldReturn() -> Bool { return false }
    func numberKeyboardShouldDeleteBackward() -> Bool { return false }
}


/**
 Specifies the style of a keyboard button.
*/
public enum IRNumberKeyboardButtonStyle: Int {
    /// A white style button, such as those for the number keys.
    case white
    /// A gray style button, such as the backspace key.
    case gray
    /// A done style button, for example, a button that completes some task and returns to the previous view.
    case done
}



/**
 A simple numeric keyboard component, with some configurable buttons.
*/
public class IRNumberKeyboard: UIInputView, UIInputViewAudioFeedback {
    
    var buttonDictionary: [String : UIButton]
    var separatorViews: [UIView]
    let locale: Locale
    weak var _keyInput: UIKeyInput?
    
    
    // MARK: - Public Accessible Variables
    
    /// The receiver key input object. If `nil` the object at top of the responder chain is used.
    public weak var keyInput: UIKeyInput? {
        
        if let input = _keyInput {
            return input
        }
        
        guard let firstResponder = UIApplication.shared.keyWindow?.firstResponder else { return nil }
        guard let firstResponderKeyInput = firstResponder as? UIKeyInput else {
            print("Warning: First responder \(firstResponder) does not conform to the UIKeyInput protocol.")
            return nil
        }
        
        _keyInput = firstResponderKeyInput
        return firstResponderKeyInput
    }

    
    /// Delegate to change text insertion or return key behavior.
    public weak var delegate: IRNumberKeyboardDelegate?

    /// If `true`, the decimal separator key will be displayed
    /// - Note: The default value of this property is `false`.
    public var allowsDecimalPoint: Bool
    
    /// The visible title of the Return key
    /// - Note: The default visible title of the Return key is “Done”.
    public var returnKeyTitle: String
    
    /// The button style of the Return key
    /// - Note: The default value of this property is `IRNumberKeyboardButtonStyle.done`
    public var returnKeyButtonStyle: IRNumberKeyboardButtonStyle
    
    
    // MARK: - Initialization
    
    /**
     Initializes and returns a number keyboard view using the specified style information and locale.
     
     An initialized view object or `nil` if the view could not be initialized.
     
     - Parameter frame:     The frame rectangle for the view, measured in points.
                            The origin of the frame is relative to the superview in which you plan to add it.
     - Parameter inputViewStyle:   The style to use when altering the appearance of the view and its subviews.
                                   For a list of possible values, see `UIInputView.Style`
     - Parameter locale:    An `NSLocale` object that specifies options (specifically the `NSLocaleDecimalSeparator`)
                            used for the keyboard. Specify `nil` if you want to use the current locale.

     - Returns: An initialized view object or `nil` if the view could not be initialized.
    */
    public init(frame: CGRect = .zero, inputViewStyle: UIInputView.Style = .keyboard, locale: Locale = .current) {
        self.buttonDictionary = [:]
        self.separatorViews = []
        self.locale = locale
        
        self.allowsDecimalPoint = false
        self.returnKeyTitle = "Done"
        self.returnKeyButtonStyle = .done
        
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
    }
    
    
    // MARK: - Configuring the special key
    
    /**
     Configures the special key with a title and an action block.

     - Parameter title:     The title to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter handler:   A handler block.
    */
    public func configureSpecialKey(withTitle title: String, buttonStyle style: IRNumberKeyboardButtonStyle, actionHandler handler: (() -> Void)) {
        
    }
    
    /**
     Configures the special key with an image and an action block.
     
     - Parameter image:     The image to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter handler:   A handler block.
    */
    public func configureSpecialKey(withImage image: UIImage, buttonStyle style: IRNumberKeyboardButtonStyle, actionHandler handler: (() -> Void)) {
        
    }
    
    /**
     Configures the special key with an image and a target-action.
     
     - Parameter title:     The title to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter target:    The target object—that is, the object to which the action message is sent.
     - Parameter action:    A selector identifying an action message. It cannot be NULL.
    */
    public func configureSpecialKey(withTitle title :String, buttonStyle style: IRNumberKeyboardButtonStyle, target: Any, action: Selector) {
        
    }
    
    /**
     Configures the special key with an image and a target-action.
     
     - Parameter image:     The image to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter target:    The target object—that is, the object to which the action message is sent.
     - Parameter action:    A selector identifying an action message. It cannot be NULL.
    */
    public func configureSpecialKey(withImage image: UIImage, buttonStyle style: IRNumberKeyboardButtonStyle, target: Any, action: Selector) {
        
    }

    
    
}

extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}
