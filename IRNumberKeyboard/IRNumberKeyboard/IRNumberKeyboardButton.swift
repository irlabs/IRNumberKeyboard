//
//  IRNumberKeyboardButton.swift
//  IRNumberKeyboard
//
//  Created by Dirk van Oosterbosch on 14/11/2019.
//  Copyright © 2019 IR Labs. All rights reserved.
//

import UIKit


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


public enum IRNumberKeyboardButtonType {
    /// A simple number keys (0 - 9)
    case number(key: String)
    /// The backspace / delete key
    case backspace
    /// The (localized) 'Done' key
    case done
    /// The special key that can be configured with either an image or a title
    case special
    /// The (localized) decimal point
    case decimalPoint
    /// An arithmetic key for calculations
    case arithmetic(key: String)
}

extension IRNumberKeyboardButtonType: Equatable {
    public static func ==(lhs: IRNumberKeyboardButtonType, rhs: IRNumberKeyboardButtonType) -> Bool {
        switch (lhs, rhs) {
            
        case (let .number(key1), let .number(key2)):
            return key1 == key2
            
        case (.backspace, .backspace):
            return true
            
        case (.done, .done):
            return true
            
        case (.special, .special):
            return true
            
        case (.decimalPoint, .decimalPoint):
            return true
            
        case (let .arithmetic(key1), let .arithmetic(key2)):
            return key1 == key2
            
        default:
            return false
        }
    }
}

class IRNumberKeyboardButton: UIButton {
    
    var style: IRNumberKeyboardButtonStyle {
        didSet {
            self.buttonStyleDidChange()
        }
    }
    let type: IRNumberKeyboardButtonType
    
    
    private var continuousPressTimer: Timer?
    private var continuousPressTimeInterval: TimeInterval?
    
    private var fillColor: UIColor
    private var highlightedFillColor: UIColor
    private var disabledFillColor: UIColor
    
    private var controlColor: UIColor
    private var highlightedControlColor: UIColor
    private var disabledControlColor: UIColor
    
    
    // MARK: - Initialization
    
    init(style: IRNumberKeyboardButtonStyle, type: IRNumberKeyboardButtonType) {
        self.style = style
        self.type = type
        
        self.fillColor = .clear
        self.highlightedFillColor = .clear
        self.disabledFillColor = .clear
        self.controlColor = .clear
        self.highlightedControlColor = .clear
        self.disabledControlColor = .clear
        
        super.init(frame: .zero)
        
        self.buttonStyleDidChange()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UIButton Methods
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let _ = newWindow {
            self.updateButtonAppearance()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.updateButtonAppearance()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.updateButtonAppearance()
        }
    }
    
    
    // MARK: - Update the Button Style
    
    private func buttonStyleDidChange() {
        let isPad = UI_USER_INTERFACE_IDIOM() == .pad
        
        var fillColor: UIColor
        var highlightedFillColor: UIColor
        var disabledFillColor: UIColor
        var disabledControlColor: UIColor

        switch self.style {
        case .white:
            fillColor = UIColor.white
            highlightedFillColor = UIColor(red: 0.82, green: 0.837, blue: 0.863, alpha: 1.0)
            disabledFillColor = UIColor.white
            disabledControlColor = UIColor(red: 0.674, green: 0.7, blue: 0.744, alpha: 1.0)
        case .gray:
            if isPad {
                fillColor = UIColor(red: 0.674, green: 0.7, blue: 0.744, alpha: 1.0)
            } else {
                fillColor = UIColor(red: 0.81, green: 0.837, blue: 0.86, alpha: 1.0)
            }
            highlightedFillColor = UIColor.white
            disabledFillColor = UIColor(red: 0.882, green: 0.891, blue: 0.90, alpha: 1.0)
            disabledControlColor = UIColor(red: 0.715, green: 0.736, blue: 0.759, alpha: 1.00)
        case .done:
            fillColor = UIColor(red: 0, green: 0.479, blue: 1.0, alpha: 1.0)
            highlightedFillColor = UIColor.white
            disabledFillColor = UIColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 1.0)
            disabledControlColor = UIColor(red: 0.86, green: 0.93, blue: 1.0, alpha: 1.0)
        }
        
        var controlColor: UIColor
        var highlightedControlColor: UIColor
        if style == .done {
            controlColor = UIColor.white
            highlightedControlColor = UIColor.black
        } else {
            controlColor = UIColor.black
            highlightedControlColor = UIColor.black
        }
        
        self.setTitleColor(controlColor, for: .normal)
        self.setTitleColor(highlightedControlColor, for: .selected)
        self.setTitleColor(highlightedControlColor, for: .highlighted)
        self.setTitleColor(disabledControlColor, for: .disabled)
        
        self.fillColor = fillColor
        self.highlightedFillColor = highlightedFillColor
        self.disabledFillColor = disabledFillColor
        self.controlColor = controlColor
        self.highlightedControlColor = highlightedControlColor
        self.disabledControlColor = disabledControlColor
        
        if isPad {
            self.layer.cornerRadius = 4.0
            self.layer.shadowColor = UIColor(red: 0.533, green: 0.541, blue: 0.556, alpha: 1.0).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
            self.layer.shadowOpacity = 1.0
            self.layer.shadowRadius = 0.0
        }
        
        self.updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        if self.isEnabled {
            if self.isHighlighted || self.isSelected {
                self.backgroundColor = highlightedFillColor
                self.imageView?.tintColor = controlColor
            } else {
                self.backgroundColor = fillColor
                self.imageView?.tintColor = highlightedControlColor
            }
        } else {
            self.backgroundColor = disabledFillColor
            self.imageView?.tintColor = disabledControlColor
        }
    }
    
    
    // MARK: - Continuous Press
    
    func addTarget(_ target: Any?, action: Selector, forContinuousPress timeInterval: TimeInterval) {
        self.continuousPressTimeInterval = timeInterval
        
        self.addTarget(target, action: action, for: .valueChanged)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        let begins = super.beginTracking(touch, with: event)
        
        if let timeInterval = continuousPressTimeInterval {
            if begins && timeInterval > 0 {
                self.beginContinuousPressDelayed()
            }
        }
        
        return begins
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        self.cancelContinuousPressIfNeeded()
    }
    
    deinit {
        self.cancelContinuousPressIfNeeded()
    }
    
    @objc
    func beginContinuousPress() {
        if let timeInterval = continuousPressTimeInterval {
            guard !isTracking || timeInterval == 0 else { return }
            continuousPressTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                        target: self,
                                                        selector: #selector(handleContinuousPressTimer(_:)),
                                                        userInfo: nil,
                                                        repeats: true)
        }
    }
    
    @objc
    func handleContinuousPressTimer(_ timer: Timer) {
        if !self.isTracking {
            self.cancelContinuousPressIfNeeded()
        }
        
        self.sendActions(for: .valueChanged)
    }
    
    func beginContinuousPressDelayed() {
        if let interval = continuousPressTimeInterval {
            self.perform(#selector(beginContinuousPress), with: nil, afterDelay: interval * 2.0)
        }
    }
    
    func cancelContinuousPressIfNeeded() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(beginContinuousPress), object: nil)
        
        if let timer = continuousPressTimer {
            timer.invalidate()
            self.continuousPressTimer = nil
        }
    }
}
