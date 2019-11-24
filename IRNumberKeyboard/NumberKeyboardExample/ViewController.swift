//
//  ViewController.swift
//  NumberKeyboardExample
//
//  Created by Dirk van Oosterbosch on 11/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit

import IRNumberKeyboard

class ViewController: UIViewController, IRNumberKeyboardDelegate {

    // Initialize this with an example UITextField
    var textField: UITextField = UITextField()
    var configuredKeyboard: IRNumberKeyboard? = nil
    var toggleButton: UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
    var isArithmeticKeyboard: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        // Create and configure the keyboard
        let keyboard = IRNumberKeyboard()
        
        // Configure ...
        keyboard.allowsDecimalPoint = true
        keyboard.delegate = self
        configuredKeyboard = keyboard
        
        // Configure an example UITextField
        textField.inputView = keyboard
        textField.text = "\(123456789)"
        textField.placeholder = "Type something…"
        textField.font = UIFont.systemFont(ofSize: 24)
        textField.contentVerticalAlignment = .top
        textField.autocorrectionType = .no
        
        self.view.addSubview(textField)
        
        // Configure the button
        toggleButton.setTitle("Toggle Extra Column", for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleArithmeticButtons), for: .touchUpInside)
        toggleButton.contentHorizontalAlignment = .center
        
        self.view.addSubview(toggleButton)
        
        // Setup Autolayout constraints
        let padding: CGFloat = 20.0
        let guide = self.view.safeAreaLayoutGuide
        
        /** Could be done *much* easier with Cartography!
         
         constrain(textField) { textField in
            textField.edges == inset(textField.superview!.edges, padding)
         }
        */
        textField.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: textField.superview, attribute: .leading, multiplier: 1.0, constant: padding)
        let trailingConstraint = NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: textField.superview, attribute: .trailing, multiplier: 1.0, constant: -padding)
        let topConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: guide, attribute: .top, multiplier: 1.0, constant: padding)
        let bottomConstraint = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: guide, attribute: .bottom, multiplier: 1.0, constant: -padding)
        self.view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        // Layout of the button
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonLeadingConstraint = NSLayoutConstraint(item: toggleButton, attribute: .leading, relatedBy: .equal, toItem: toggleButton.superview, attribute: .leading, multiplier: 1.0, constant: padding)
        let buttonTrailingConstraint = NSLayoutConstraint(item: toggleButton, attribute: .trailing, relatedBy: .equal, toItem: toggleButton.superview, attribute: .trailing, multiplier: 1.0, constant: -padding)
        let buttonBottomConstraint = NSLayoutConstraint(item: toggleButton, attribute: .bottom, relatedBy: .equal, toItem: guide, attribute: .bottom, multiplier: 1.0, constant: -(padding + 280))
        self.view.addConstraints([buttonLeadingConstraint, buttonTrailingConstraint, buttonBottomConstraint])

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textField.becomeFirstResponder()
    }
    
    
    /**
     This example demonstrates an arithmetic keyboard with math key to perform specific arithmetic
     operations (devide/multiply/minus/plus).
     
     Features:
     - The arithmetic keyboard can be dynamically toggled on and off.
     - The default image and default behavior of the special key can be configured dynamically.
     - The arithmetic keys are appended in their own column.
     - The numeric keys have calculator layout.
     - The special key is configured with a special (plusMinusSign) keyboard image 
     - The tapped arithmetic key will be prepended to the start of the input string,
     -    or removed if already there.
    */
    
    // Configure the keyboard with Extra Arithmetic Columns
    @objc
    func toggleArithmeticButtons() {
        guard let keyboard = configuredKeyboard else { return }
        
        isArithmeticKeyboard = !isArithmeticKeyboard
        if isArithmeticKeyboard {
            
            // Configure with Arithmetic keys
            let arithmeticSigns = ["÷", "×", "−", "+"]
            let extraKeys: [IRNumberKeyboardButtonType] = arithmeticSigns.map { .arithmetic(key: $0) }
            keyboard.calculatorLayout = true
            keyboard.configureExtraColumn(withKeys: extraKeys, buttonStyle: .gray) { [weak self] key in
                guard let `self` = self else { return }
                
                if arithmeticSigns.contains(key), var text = self.textField.text {
                    var addSign: Bool = true
                    if let firstChar = text.first, arithmeticSigns.contains(String(firstChar)) {
                        if String(firstChar) == key {
                            addSign = false
                        }
                        text.removeFirst(2)
                    }
                    if addSign {
                        text = "\(key) " + text
                    }
                    self.textField.text = text
                }
                print(key)
            }
            keyboard.configureSpecialKey(withImage: IRNumberKeyboardImage.plusMinusSign.image(),
                                         buttonStyle: .white, target: self, action: #selector(handleSpecialKey))
        } else {
            // Configure as default
            keyboard.calculatorLayout = false
            keyboard.configureExtraColumn(withKeys: [], buttonStyle: .gray) { _ in }
            keyboard.configureSpecialKeyAsDefault()
        }
    }
    
    @objc
    func handleSpecialKey() {
        print("special key")
    }
    
    // MARK: - IRNumberKeyboard Delegate Methods
    // (Adoption is optional)
    
    func numberKeyboardShouldDeleteBackward(_ numberKeyboard: IRNumberKeyboard) -> Bool {
        return true
    }

    func numberKeyboardShouldInsertArithmetic(_ numberKeyboard: IRNumberKeyboard, key: String) -> Bool {
        return false
    }
}

