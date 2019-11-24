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
    
    var extraColumnKeys: [IRNumberKeyboardButtonType]
    var extraColumnStyle: IRNumberKeyboardButtonStyle
    let locale: Locale
    
    var specialKeyHandler: (() -> Void)?
    var extraColumnHandler: ((String) -> Void)?
    
    weak var _keyInput: UIKeyInput?
    
    
    private let numberOfRows: Int = 4
    private let buttonRowHeight: CGFloat = 55.0
    private let padBorder: CGFloat = 7.0
    private let padSpacing: CGFloat = 8.0
    
    private let buttonFont = UIFont.systemFont(ofSize: 28.0, weight: .light)
    private let doneButtonFont = UIFont.systemFont(ofSize: 17.0)

    
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
        
        self.extraColumnKeys = []
        self.extraColumnStyle = .white
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
        backspaceButton.setImage(keyboardImage(named: "delete"), for: .normal)
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
        if let dismissImage = keyboardImage(named: "dismiss") {
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
    public func configureSpecialKey(withTitle title: String,
                                    buttonStyle style: IRNumberKeyboardButtonStyle,
                                    actionHandler handler: @escaping (() -> Void)) {
        guard let button = specialButton else { return }
        button.setTitle(title, for: .normal)
        button.style = style
        button.setImage(nil, for: .normal)
        self.specialKeyHandler = handler
    }
    
    /**
     Configures the special key with an image and an action block.
     
     - Parameter image:     The image to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter handler:   A handler block.
    */
    public func configureSpecialKey(withImage image: UIImage,
                                    buttonStyle style: IRNumberKeyboardButtonStyle,
                                    actionHandler handler: @escaping (() -> Void)) {
        guard let button = specialButton else { return }
        button.setTitle(nil, for: .normal)
        button.style = style
        button.setImage(image, for: .normal)
        self.specialKeyHandler = handler
    }
    
    /**
     Configures the special key with an image and a target-action.
     
     - Parameter title:     The title to display in the key.
     - Parameter style:     The style of the button key.
     - Parameter target:    The target object—that is, the object to which the action message is sent.
     - Parameter action:    A selector identifying an action message. It cannot be `nil`.
    */
    public func configureSpecialKey(withTitle title :String,
                                    buttonStyle style: IRNumberKeyboardButtonStyle,
                                    target: Any?, action: Selector) {
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
    public func configureSpecialKey(withImage image: UIImage,
                                    buttonStyle style: IRNumberKeyboardButtonStyle,
                                    target: Any?, action: Selector) {
        self.configureSpecialKey(withImage: image, buttonStyle: style) { [weak self] in
            guard let `self` = self else { return }
            UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
        }
    }
    
    
    // MARK: - Configuring the extra keys column
    
    /**
     Configures an extra column of keys and an action block.
     The extra column can be dynamically added or removed by providing an array of keys or an empty array.
     
     - Parameter keyTypes:  An array of `IRNumberKeyboardButtonType` key types. The array should be the number of rows (4) buttons long or empty to remove the column.
     - Parameter style:     The style of the button keys.
     - Parameter handler:   A handler block to be invoked if any or the keys is tapped.
     The first argument of the handler is the `key: String` of the tapped button.
     */
    public func configureExtraColumn(withKeys keyTypes: [IRNumberKeyboardButtonType],
                                     buttonStyle style: IRNumberKeyboardButtonStyle,
                                     actionHandler handler: @escaping ((String) -> Void)) {
        // Check if the array of buttons is the number of rows long
        guard keyTypes.isEmpty || keyTypes.count == numberOfRows else {
            print("Warning: the number of key types of the extra column is not matching the number of rows. Discarding.")
            return
        }
        
        // Remove old keys
        for type in extraColumnKeys {
            guard let index = keyboardButtons.firstIndex(where: { $0.type == type }) else { continue }
            let button = keyboardButtons[index]
            button.removeFromSuperview()
            keyboardButtons.remove(at: index)
        }
        
        self.extraColumnKeys = keyTypes
        self.extraColumnStyle = style
        
        // Add new keys
        for type in extraColumnKeys {
            let button = IRNumberKeyboardButton(style: extraColumnStyle, type: type)
            let title: String = {
                switch type {
                case .number(let key):
                    return key
                case .arithmetic(let key):
                    return key
                default:
                    return ""
                }
            }()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = buttonFont
            keyboardButtons.append(button)
            
            button.isExclusiveTouch = true
            button.addTarget(self, action: #selector(buttonInput(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonClickPlay), for: .touchDown)
            
            addSubview(button)
        }

        self.extraColumnHandler = handler
    }
    
    
    // MARK: - Computed Accessor Methods
    
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
        
        // Extra column handler
        if extraColumnKeys.contains(button.type) {
            let key: String = {
                switch button.type {
                case .number(let key):
                    return key
                case .arithmetic(let key):
                    return key
                default:
                    return ""
                }
            }()
            if let handler = extraColumnHandler {
                handler(key)
            }
        }
        
        switch button.type {
            
        // Numbers
        case .number(let key):
            guard delegate?.numberKeyboardShouldInsert(self, text: key) ?? true else { return }
            keyInput.insertText(key)
            
        // Backspace
        case .backspace:
            if delegate?.numberKeyboardShouldDeleteBackward(self) ?? true {
                keyInput.deleteBackward()
            }
        
        // Done
        case .done:
            if delegate?.numberKeyboardShouldReturn(self) ?? true {
                self.dismissKeyboard()
            }
        
        // Decimal Point
        case .decimalPoint:
            guard let decimalSeparator = button.title(for: .normal) else { return }
            guard delegate?.numberKeyboardShouldInsert(self, text: decimalSeparator) ?? true else { return }
            keyInput.insertText(decimalSeparator)

        // Special Key
        case .special:
            if let handler = specialKeyHandler {
                handler()
            }
            
        // Arithmetic
        case .arithmetic(let key):
            guard delegate?.numberKeyboardShouldInsertArithmetic(self, key: key) ?? true else { return }
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
        
        let insets: UIEdgeInsets = {
            if #available(iOS 11.0, *) {
                return safeAreaInsets
            } else {
                return UIEdgeInsets.zero
            }
        }()
        
        let isPad = UI_USER_INTERFACE_IDIOM() == .pad
        let spacing: CGFloat = isPad ? padBorder : 0
        let numberOfColumns: Int = extraColumnKeys.isEmpty ? 4 : 5
        let widthOnPad: CGFloat = CGFloat(numberOfColumns) * 100
        let width: CGFloat = isPad ? min(widthOnPad, bounds.width) : bounds.width
        
        let contentRect = CGRect(x: (bounds.width - width) / 2.0,
                                 y: spacing,
                                 width: width,
                                 height: bounds.height - (spacing * 2)
            ).inset(by: insets)
        
        let columnWidth: CGFloat = contentRect.width / CGFloat(numberOfColumns)
        let rowHeight: CGFloat = contentRect.height / CGFloat(numberOfRows)
        
        // Number buttons
        let numberButtonSize: CGSize = CGSize(width: columnWidth, height: rowHeight)
        let numbersOffset: CGFloat = extraColumnKeys.isEmpty ? 0 : columnWidth
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
                rect.origin.x = numberButtonSize.width + numbersOffset
                
                if !allowsDecimalPoint {
                    rect.size.width = numberButtonSize.width * 2
                    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: numberButtonSize.width)
                }
            } else {
                
                // Other numbers (1 - 9)
                let line: CGFloat = CGFloat((i - 1) / numbersPerLine)
                let pos: CGFloat = CGFloat((i - 1) % numbersPerLine)
                
                rect.origin.y = line * numberButtonSize.height
                rect.origin.x = pos * numberButtonSize.width + numbersOffset
            }
            
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Extra Column Keys
        for (i, type) in extraColumnKeys.enumerated() {
            guard let button = keyboardButtons.first(where: { $0.type == type }) else {
                return
            }
            
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            rect.origin.y = CGFloat(i) * numberButtonSize.height
            rect.origin.x = 0
            
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Special Key
        if let button = specialButton {
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            rect.origin.y = numberButtonSize.height * 3
            rect.origin.x = numbersOffset
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Decimal Point
        if let button = decimalPointButton {
            var rect = CGRect(origin: .zero, size: numberButtonSize)
            rect.origin.y = numberButtonSize.height * 3
            rect.origin.x = numberButtonSize.width * 2 + numbersOffset
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
            button.isHidden = !allowsDecimalPoint
        }
        
        // Utility Column
        let utilityButtonSize: CGSize = CGSize(width: columnWidth, height: rowHeight * 2)
        for (i, type) in [IRNumberKeyboardButtonType.backspace, IRNumberKeyboardButtonType.done].enumerated() {
            guard let button = keyboardButtons.first(where: { $0.type == type }) else { return }
            
            var rect = CGRect(origin: .zero, size: utilityButtonSize)
            rect.origin.x = columnWidth * 3 + numbersOffset
            rect.origin.y = CGFloat(i) * utilityButtonSize.height
            button.frame = buttonRect(rect, contentRect: contentRect, isPad: isPad)
        }
        
        // Layout separators if iPhone
        if !isPad {
            let hasSafeArea = insets != .zero
            let totalRows = numberOfRows + (hasSafeArea ? 1 : 0)
            let totalColumns = numberOfColumns + (hasSafeArea ? 2 : 0)
            let startAtCol = hasSafeArea ? 0 : 1
            let numberOfSeparators = totalRows + totalColumns - 1
            
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
                        // For the big backspace and return buttons in the right column
                        rect.size.width = contentRect.width - columnWidth
                    } else {
                        rect.size.width = contentRect.width
                    }
                    rect.size.height = separatorDimension;
                } else {
                    let col = i - totalRows
                    
                    rect.origin.x = CGFloat(col + startAtCol) * columnWidth
                    rect.size.width = separatorDimension
                    
                    if (col == 2 - startAtCol && !allowsDecimalPoint) {
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
        
        let insets: UIEdgeInsets = {
            if #available(iOS 11.0, *) {
                return UIApplication.shared.delegate?.window??.safeAreaInsets ?? safeAreaInsets
            } else {
                return UIEdgeInsets.zero
            }
        }()

        returnSize.height = buttonRowHeight * CGFloat(numberOfRows) + (spacing * 2.0) + insets.bottom
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
    
    private func keyboardImage(named: String) -> UIImage? {
        let bundle = Bundle(for: type(of: self))
        return UIImage.init(named: named, in: bundle, compatibleWith: nil)
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
