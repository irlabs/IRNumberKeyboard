//
//  ViewController.swift
//  NumberKeyboardExample
//
//  Created by Dirk van Oosterbosch on 11/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit

import IRNumberKeyboard

class ViewController: UIViewController {

    // Initialize this with an example UITextField
    var textField: UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        // Create and configure the keyboard
        let keyboard = IRNumberKeyboard()
        // configure ...
        
        // Configure an example UITextField
        textField.inputView = keyboard
        textField.text = "\(123456789)"
        textField.placeholder = "Type something…"
        textField.font = UIFont.systemFont(ofSize: 24)
        textField.contentVerticalAlignment = .top
        
        self.view.addSubview(textField)
        
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
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textField.becomeFirstResponder()
    }

}

