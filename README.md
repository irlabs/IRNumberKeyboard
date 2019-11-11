# IRNumberKeyboard

A simple numeric keyboard component, with some configurable buttons, build in Swift for iOS.

![]()

This keyboard was inspired by the [MMNumberKeyboard](https://github.com/matmartinez/MMNumberKeyboard) )

## Installation

### From Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager for Objective-C and Swift. Add the following line to your `Cartfile`:

```
github "irlabs/IRNumberKeyboard"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) for up to date installation instructions.

### From CocoaPods

If your looking for a numeric keyboard library which you can install through CocoaPods, have a look at [MMNumberKeyboard](https://github.com/matmartinez/MMNumberKeyboard)

## Usage

In the Xcode project, there is a an example Target *NumberKeyboardExample*. Build & Run that target and play around.

Basically you instantiate your own keyboard view to use as an `.inputView` of your `UITextField`, `UITextView` or whatever view that supports text editing.

```swift
// Create and configure the keyboard.
// MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
// keyboard.allowsDecimalPoint = YES;
// keyboard.delegate = self;

// Configure an example UITextField.
// UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
// textField.inputView = keyboard;
```

You can adopt the `IRNumberKeyboardDelegate` protocol to handle the return key or whether text should be inserted or not.
