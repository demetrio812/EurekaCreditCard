# EurekaCreditCard

[![CI Status](http://img.shields.io/travis/Demetrio Filocamo/EurekaCreditCard.svg?style=flat)](https://travis-ci.org/Demetrio Filocamo/EurekaCreditCard)
[![Version](https://img.shields.io/cocoapods/v/EurekaCreditCard.svg?style=flat)](http://cocoapods.org/pods/EurekaCreditCard)
[![License](https://img.shields.io/cocoapods/l/EurekaCreditCard.svg?style=flat)](http://cocoapods.org/pods/EurekaCreditCard)
[![Platform](https://img.shields.io/cocoapods/p/EurekaCreditCard.svg?style=flat)](http://cocoapods.org/pods/EurekaCreditCard)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

EurekaCreditCard is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EurekaCreditCard"
```

## Code
```swift
form +++= Section("Credit card information")

                <<< CreditCardRow() {
            //$0.title = "Card"
            $0.cardNumberPlaceholder = "Card Number"
            $0.expirationMonthPlaceholder = "MM"
            $0.expirationYearPlaceholder = "YY"
            $0.cvcPlaceholder = "CVC"
            //$0.dataSectionWidthPercentage = CGFloat(0.5)
//            $0.value = CreditCard()
            $0.value = CreditCard(
            cardNumber: "1",
                    expirationMonth: "02",
                    expirationYear: "2018",
                    cvc: "4"
            )
        }
```

## Screenshots

##### Styles
![Styles](demo_styles.png)

##### Selectors for month and year
![Selectors for month and year](demo_selector.png)

### TODO
* pod specs
* SwiftValidator integration?

## Author

Demetrio Filocamo, filocamo@demetrio.it

## License

EurekaCreditCard is available under the MIT license. See the LICENSE file for more info.
