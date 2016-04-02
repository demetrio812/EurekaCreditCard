//
//  ViewController.swift
//  Examples
//
//  Created by Demetrio Filocamo on 02/04/2016.
//  Copyright © 2016 Novaware Ltd. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        form +++ Section("Credit card information")

                <<< CreditCardRow() {
            //$0.title = "Card"
            //$0.dataSectionWidthPercentage = CGFloat(0.5)
            $0.cardNumberPlaceholder = "Card Number"
            $0.expirationMonthPlaceholder = "MM"
            $0.expirationYearPlaceholder = "YY"
            $0.cvcPlaceholder = "CVC"
            $0.value = CreditCard()
        }

        form +++= Section("Credit card information (Example 2)")
                <<< CreditCardRow() {
            $0.title = "Card"
            //$0.dataSectionWidthPercentage = CGFloat(0.5)
            $0.cardNumberPlaceholder = "Card Number"
            $0.expirationMonthPlaceholder = "MM"
            $0.expirationYearPlaceholder = "YY"
            $0.cvcPlaceholder = "CVC"
            $0.value = CreditCard(
            cardNumber: "4242424242424242",
                    expirationMonth: "02",
                    expirationYear: "2018",
                    cvc: "123"
            )
        }

        form +++= Section("Credit card information (Example 3)")
                <<< CreditCardRow() {
            $0.title = "Main Card"
            $0.dataSectionWidthPercentage = CGFloat(0.6)
            $0.cardNumberPlaceholder = "Card Number"
            $0.expirationMonthPlaceholder = "MM"
            $0.expirationYearPlaceholder = "YY"
            $0.cvcPlaceholder = "CVC"
            $0.value = CreditCard(
            cardNumber: "4242424242424242",
                    expirationMonth: "02",
                    expirationYear: "2018",
                    cvc: "123"
            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

