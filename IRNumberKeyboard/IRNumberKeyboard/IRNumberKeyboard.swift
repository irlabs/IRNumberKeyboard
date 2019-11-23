//
//  IRNumberKeyboard.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 13/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit


/**
 A simple numeric keyboard component, with some configurable buttons.
*/
public class IRNumberKeyboard: UIInputView, UIInputViewAudioFeedback {
    
    var keyboardButtons: [IRNumberKeyboardButton]
    var separatorViews: [UIView]
    let locale: Locale
    
    var specialHandler: (() -> Void)?
    
    weak var _keyInput: UIKeyInput?
    
    
    private let numberOfRows: Int = 4
    private let rowHeight: CGFloat = 55.0
    private let padBorder: CGFloat = 7.0
    private let padSpacing: CGFloat = 8.0
    
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
    public var allowsDecimalPoint: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The visible title of the Return key
    /// - Note: The default visible title of the Return key is “Done”.
    public var returnKeyTitle: String {
        get {
            var title = _returnKeyTitle
            if let button = doneButton, let titleForNormal = button.title(for: .normal) {
                title = titleForNormal
            }
            return title.isEmpty ? localizedSystemString("Done") : title
        }
        set {
            if _returnKeyTitle != newValue {
                if let button = doneButton {
                    _returnKeyTitle = newValue.isEmpty ? localizedSystemString("Done") : newValue
                    button.setTitle(_returnKeyTitle, for: .normal)
                }
            }
        }
    }
    private var _returnKeyTitle: String
    
    /// The button style of the Return key
    /// - Note: The default value of this property is `IRNumberKeyboardButtonStyle.done`
    public var returnKeyButtonStyle: IRNumberKeyboardButtonStyle {
        didSet {
            if let button = doneButton {
                button.style = returnKeyButtonStyle
            }
        }
    }
    
    
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
        self.keyboardButtons = []
        self.separatorViews = []
        self.locale = locale
        
        self.allowsDecimalPoint = false
        self._returnKeyTitle = "Done"
        self.returnKeyButtonStyle = .done
        
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        let buttonFont = UIFont.systemFont(ofSize: 28.0, weight: .light)
        let doneButtonFont = UIFont.systemFont(ofSize: 17.0)
        
        // Number buttons
        for i in 0...9 {
            let key = "\(i)"
            let button = IRNumberKeyboardButton(style: .white, type: .number(key: key))
            button.setTitle(key, for: .normal)
            button.titleLabel?.font = buttonFont
            
            keyboardButtons.append(button)
        }
        
        // Backspace button
        let backspaceButton = IRNumberKeyboardButton(style: .gray, type: .backspace)
        backspaceButton.setImage(UIImage(named: "delete"), for: .normal)
        backspaceButton.addTarget(self, action: #selector(backspaceRepeat(_:)), forContinuousPress: 0.15)
        keyboardButtons.append(backspaceButton)
        
        // Special button
        let specialButton = IRNumberKeyboardButton(style: .gray, type: .special)
        keyboardButtons.append(specialButton)
        
        // Done button
        let doneButton = IRNumberKeyboardButton(style: .done, type: .done)
        doneButton.setTitle(localizedSystemString("Done"), for: .normal)
        doneButton.titleLabel?.font = doneButtonFont
        keyboardButtons.append(doneButton)
        
        // Decimal point button
        let decimalPointButton = IRNumberKeyboardButton(style: .white, type: .decimalPoint)
        let decimalSeparator = Locale.current.decimalSeparator ?? "."
        decimalPointButton.setTitle(decimalSeparator, for: .normal)
        keyboardButtons.append(decimalPointButton)

        
        // Button Actions & Add to view
        for button in keyboardButtons {
            button.isExclusiveTouch = true
            button.addTarget(self, action: #selector(buttonInput(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonClickPlay), for: .touchDown)
            
            addSubview(button)
        }
        
        // Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleHighlight(gestureRecognizer:)))
        addGestureRecognizer(panGesture)
        
        
        // Default Special key
        if let dismissImage = UIImage(named: "dismiss") {
            self.configureSpecialKey(withImage: dismissImage, buttonStyle: .gray, target: self, action: #selector(dismissKeyboard))
        }
        
        // Default Return Key
        self.returnKeyTitle = localizedSystemString("Done")
        self.returnKeyButtonStyle = .done
        
        // Size to fit (will trigger layout)
        self.sizeToFit()
    }
    
    
    // MARK: - Configuring the special key
    
    /**
     Configures the special key with a title and an action block.

     - Parameter title:     The title to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter handler:   A handler block.
    */
    public func configureSpecialKey(withTitle title: String, buttonStyle style: IRNumberKeyboardButtonStyle, actionHandler handler: @escaping (() -> Void)) {
        guard let button = specialButton else { return }
        button.setTitle(title, for: .normal)
        button.style = style
        button.setImage(nil, for: .normal)
        self.specialHandler = handler
    }
    
    /**
     Configures the special key with an image and an action block.
     
     - Parameter image:     The image to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter handler:   A handler block.
    */
    public func configureSpecialKey(withImage image: UIImage, buttonStyle style: IRNumberKeyboardButtonStyle, actionHandler handler: @escaping (() -> Void)) {
        guard let button = specialButton else { return }
        button.setTitle(nil, for: .normal)
        button.style = style
        button.setImage(image, for: .normal)
        self.specialHandler = handler
    }
    
    /**
     Configures the special key with an image and a target-action.
     
     - Parameter title:     The title to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter target:    The target object—that is, the object to which the action message is sent.
     - Parameter action:    A selector identifying an action message. It cannot be `nil`.
    */
    public func configureSpecialKey(withTitle title :String, buttonStyle style: IRNumberKeyboardButtonStyle, target: Any?, action: Selector) {
        self.configureSpecialKey(withTitle: title, buttonStyle: style) { [weak self] in
            guard let `self` = self else { return }
            UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
        }
    }
    
    /**
     Configures the special key with an image and a target-action.
     
     - Parameter image:     The image to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter target:    The target object—that is, the object to which the action message is sent.
     - Parameter action:    A selector identifying an action message. It cannot be `nil`.
    */
    public func configureSpecialKey(withImage image: UIImage, buttonStyle style: IRNumberKeyboardButtonStyle, target: Any?, action: Selector) {
        self.configureSpecialKey(withImage: image, buttonStyle: style) { [weak self] in
            guard let `self` = self else { return }
            UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
        }
    }
    
    
    private var specialButton: IRNumberKeyboardButton? {
        return keyboardButtons.first { $0.type == .special }
    }
    
    private var doneButton: IRNumberKeyboardButton? {
        return keyboardButtons.first { $0.type == .done }
    }
    
    private var decimalPointButton: IRNumberKeyboardButton? {
        return keyboardButtons.first { $0.type == .decimalPoint }
    }
    
    // MARK: - Input
    
    @objc
    private func handleHighlight(gestureRecognizer: UIPanGestureRecognizer) {
        
        let point = gestureRecognizer.location(in: self)
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            for button in keyboardButtons {
                let isInside = button.frame.contains(point) && !button.isHidden
                
                if gestureRecognizer.state == .changed {
                    button.isHighlighted = isInside
                } else {
                    button.isHighlighted = false
                }
                
                if gestureRecognizer.state == .ended && isInside {
                    button.sendActions(for: .touchUpInside)
                }
            }
        }
    }

    @objc
    private func buttonClickPlay() {
        UIDevice.current.playInputClick()
    }

    @objc
    private func buttonInput(_ button: IRNumberKeyboardButton) {
        
        // Get first responder
        guard let keyInput = keyInput else { return }

        switch button.type {
            
        // Numbers
        case .number(let key):
            guard let delegate = delegate else { return }
            guard delegate.numberKeyboardShouldInsert(text: key) else { return }
            keyInput.insertText(key)
            
        // Backspace
        case .backspace:
            if delegate?.numberKeyboardShouldDeleteBackward() ?? true {
                keyInput.deleteBackward()
            }
        
        // Done
        case .done:
            if delegate?.numberKeyboardShouldReturn() ?? true {
                self.dismissKeyboard()
            }
        
        // Decimal Point
        case .decimalPoint:
            guard let delegate = delegate else { return }
            guard let decimalSeparator = button.title(for: .normal) else { return }
            guard delegate.numberKeyboardShouldInsert(text: decimalSeparator) else { return }
            keyInput.insertText(decimalSeparator)

        // Special Key
        case .special:
            if let handler = specialHandler {
                handler()
            }
            
        // Arithmetic
        case .arithmetic(let key):
            guard let delegate = delegate else { return }
            guard delegate.numberKeyboardShouldInsert(text: key) else { return }
            keyInput.insertText(key)

        }
    }

    @objc
    private func backspaceRepeat(_ button: IRNumberKeyboardButton) {
        guard let input = keyInput  else { return }
        guard input.hasText else { return }
        
        buttonClickPlay()
        buttonInput(button)
    }
    
    
    // MARK: - Dismiss the Keyboard
    
    @objc
    private func dismissKeyboard() {
        guard let keyInput = keyInput as? UIResponder else { return }
        keyInput.resignFirstResponder()
    }
    
    
    // MARK: - Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let isPad = UI_USER_INTERFACE_IDIOM() == .pad
        let spacing: CGFloat = isPad ? padBorder : 0
        let width: CGFloat = isPad ? min(400, bounds.width) : bounds.width
        
        let contentRect = CGRect(x: (bounds.width - width) / 2.0,
                                 y: spacing,
                                 width: width,
                                 height: bounds.height - (spacing * 2))
        let columnWidth: CGFloat = contentRect.width / 4
        
        // Number buttons
        let numberButtonSize: CGSize = CGSize(width: columnWidth, height: rowHeight)
        let numbersPerLine = 3
        
        for i in 0...9 {
            let key = "\(i)"
            guard let button = keyboardButtons.first(where: { $0.type == .number(key: key) }) else {
                return
            }
            
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            if i == 0 {
                
                // 0 Key
                rect.origin.y = numberButtonSize.height * 3
                rect.origin.x = numberButtonSize.width
                
                if !allowsDecimalPoint {
                    rect.size.width = numberButtonSize.width * 2
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: numberButtonSize.width)
                }
            } else {
                
                // Other numbers (1 - 9)
                let line: CGFloat = CGFloat((i - 1) / numbersPerLine)
                let pos: CGFloat = CGFloat((i - 1) % numbersPerLine)
                
                rect.origin.y = line * numberButtonSize.height
                rect.origin.x = pos * numberButtonSize.width
            }
            
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Special Key
        if let button = specialButton {
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            rect.origin.y = numberButtonSize.height * 3
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Decimal Point
        if let button = decimalPointButton {
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            rect.origin.y = numberButtonSize.height * 3
            rect.origin.x = numberButtonSize.width * 2
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
            button.isHidden = !allowsDecimalPoint
        }
        
        // Utility Column
        let utilityButtonSize: CGSize = CGSize(width: columnWidth, height: rowHeight * 2)
        for (i, type) in [IRNumberKeyboardButtonType.backspace, IRNumberKeyboardButtonType.done].enumerated() {
            guard let button = keyboardButtons.first(where: { $0.type == type }) else { return }
            
            var rect = CGRect(origin: .zero, size: utilityButtonSize)
            rect.origin.x = columnWidth * 3
            rect.origin.y = CGFloat(i) * utilityButtonSize.height
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Layout separators if iPhone
        if !isPad {
            let totalColumns = 4
            let totalRows = numbersPerLine + 1
            let numberOfSeparators = totalColumns + totalRows - 1
            
            if separatorViews.count != numberOfSeparators {
                // Remove all old ones
                separatorViews.forEach { $0.removeFromSuperview() }
                separatorViews = []
                // Add new
                for _ in 0..<numberOfSeparators {
                    let separator = UIView()
                    separator.backgroundColor = UIColor(white: 0, alpha: 0.1)
                    self.addSubview(separator)
                    separatorViews.append(separator)
                }
            }
            
            let separatorDimension: CGFloat = 1.0 / UIScreen.main.scale
            for (i, separator) in separatorViews.enumerated() {
                var rect: CGRect = .zero
                
                if i < totalRows {
                    rect.origin.y = CGFloat(i) * rowHeight
                    if (i % 2) > 0 {
                        rect.size.width = contentRect.width - columnWidth
                    } else {
                        rect.size.width = contentRect.width
                    }
                    rect.size.height = separatorDimension;
                } else {
                    let col = i - totalRows
                    
                    rect.origin.x = CGFloat(col + 1) * columnWidth
                    rect.size.width = separatorDimension
                    
                    if (col == 1 && !allowsDecimalPoint) {
                        rect.size.height = contentRect.height - rowHeight
                    } else {
                        rect.size.height = contentRect.height
                    }
                }
                separator.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
            }
        }
    }
    
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var returnSize = size
        let isPad = UI_USER_INTERFACE_IDIOM() == .pad
        let spacing: CGFloat = isPad ? padBorder : 0.0
        
        returnSize.height = rowHeight * CGFloat(numberOfRows) + (spacing * 2.0)
        if returnSize.width == 0.0 {
            returnSize.width = UIScreen.main.bounds.size.width
        }
        
        return returnSize
    }
    
    
    private func buttonRect(_ rect: CGRect, contentRect: CGRect, isPad: Bool) -> CGRect {
        var returnRect = rect.offsetBy(dx: contentRect.origin.x, dy: contentRect.origin.y)
        
        if isPad {
            let inset: CGFloat = padSpacing / 2.0
            returnRect = returnRect.insetBy(dx: inset, dy: inset)
        }
        
        return returnRect
    }
    
    
    // MARK: - Localized System String
    
    private func localizedSystemString(_ systemText: String) -> String {
        let bundle = Bundle(identifier: "com.apple.UIKit")
        return bundle?.localizedString(forKey: systemText, value: "", table: nil) ?? systemText
    }
    
    
    // MARK: - Audio Feedback
    
    public var enableInputClicksWhenVisible: Bool {
        return true
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
