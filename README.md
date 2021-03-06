# IRNumberKeyboard

A simple numeric keyboard component, with some configurable buttons, build in Swift for iOS.

![Different devices and different configurations](Screenshots.png)

( This keyboard was inspired by the [MMNumberKeyboard](https://github.com/matmartinez/MMNumberKeyboard) )

## Features

- A special key can be configured with both image or title.
- The default (dismiss) image and default behavior of the special key can be set.
- An extra (5th) column of keys can be configured
- Special key and Extra keys can be disabled
- Layout of the number keys can be configured: telephone layout or calculator layout
- Keyboard images can be retrieved through helper enum (a.o. a special `plusMinusSign` image)
- Special sample code showing use of arithmetic buttons

## Installation

### From Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager for Objective-C and Swift. Add the following line to your `Cartfile`:

```
github "irlabs/IRNumberKeyboard"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for up to date installation instructions.

### From CocoaPods

Currently **IRNumberKeyboard** *does not* support CocoaPods.

If your looking for a numeric keyboard library which you can install through CocoaPods, have a look at [MMNumberKeyboard](https://github.com/matmartinez/MMNumberKeyboard)

## Usage

In the Xcode project, there is a an example Target *NumberKeyboardExample*. Build & Run that target and play around.

Basically you instantiate your own keyboard view to use as an `.inputView` of your `UITextField`, `UITextView` or whatever view that supports text editing.

```swift
// Create and configure the keyboard.
let keyboard = IRNumberKeyboard()
keyboard.allowsDecimalPoint = true
keyboard.delegate = self

// Configure an example UITextField.
let textField = UITextField()
textField.inputView = keyboard
```

You can adopt the `IRNumberKeyboardDelegate` protocol to handle the return key or whether text should be inserted or not.
