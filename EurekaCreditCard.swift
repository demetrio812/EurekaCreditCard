//
//  EurekaCreditCard.swift
//  Examples
//
//  Created by Demetrio Filocamo on 02/04/2016.
//  Copyright © 2016 Novaware Ltd. All rights reserved.
//
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Eureka
import BKMoneyKit

public protocol CreditCardRowConformance {
    var dataSectionWidthPercentage: CGFloat? { get set }
    var placeholderColor: UIColor? { get set }
    var cardNumberPlaceholder: String? { get set }
    var expirationMonthPlaceholder: String? { get set }
    var expirationYearPlaceholder: String? { get set }
    var cvcPlaceholder: String? { get set }
}

/**
 *  Protocol for cells that contain a postal address
 */

public protocol CreditCardCellConformance {
    var cardNumberTextField: BKCardNumberField { get }
    var expirationMonthTextField: UITextField { get }
    var expirationYearTextField: UITextField { get }
    var cvcTextField: UITextField { get }
}

/**
 *  Protocol to be implemented by CreditCard types.
 */

public protocol CreditCardType: Equatable {
    var cardNumber: String? { get set }
    var expirationMonth: String? { get set }
    var expirationYear: String? { get set }
    var cvc: String? { get set }
}

public func ==<T:CreditCardType>(lhs: T, rhs: T) -> Bool {
    return lhs.cardNumber == rhs.cardNumber && lhs.expirationMonth == rhs.expirationMonth && lhs.expirationYear == rhs.expirationYear && lhs.cvc == rhs.cvc
}

public struct CreditCard: CreditCardType {
    public var cardNumber: String?
    public var expirationMonth: String?
    public var expirationYear: String?
    public var cvc: String?
    
    public init() {
    }
    
    public init(cardNumber: String?, expirationMonth: String?, expirationYear: String?, cvc: String?) {
        self.cardNumber = cardNumber
        self.expirationMonth = expirationMonth
        self.expirationYear = expirationYear
        self.cvc = cvc
    }
}

public class CreditCardCell<T:CreditCardType>: Cell<T>, CellType, CreditCardCellConformance, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    public var months = [String]()
    public var monthsName = [String]()
    public var years = [String]()
    
    public lazy var pickerMonth: UIPickerView = {
        [unowned self] in
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
        }()
    
    public lazy var pickerYear: UIPickerView = {
        [unowned self] in
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
        }()
    
    lazy public var cardNumberTextField: BKCardNumberField = {
        let textField = BKCardNumberField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var cardNumberSeparatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGrayColor()
        return separatorView
    }()
    
    lazy public var expirationMonthTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var expirationMonthYearSeparatorLabel: UILabel = {
        let label = UILabel()
        label.text = "/"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy public var expirationYearTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var cvcTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var titleLabel: UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        textLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        return textLabel
    }
    
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        cardNumberTextField.delegate = nil
        cardNumberTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        expirationMonthTextField.delegate = nil
        expirationMonthTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        expirationYearTextField.delegate = nil
        expirationYearTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        cvcTextField.delegate = nil
        cvcTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
        
        pickerMonth.delegate = nil
        pickerMonth.dataSource = nil
        pickerYear.delegate = nil
        pickerYear.dataSource = nil
    }
    
    public override func setup() {
        super.setup()
        height = {
            60
        }
        selectionStyle = .None
        
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        monthsName = dateFormatter.shortMonthSymbols
        
        for myMonthInt in 1 ... 12 {
            months.append(String(format: "%02d", myMonthInt))
        }
        let currentYear = NSCalendar.currentCalendar().component(.Year, fromDate: NSDate())
        for myYearInt in currentYear ... (currentYear + 20) {
            years.append(String(myYearInt))
        }
        
        contentView.addSubview(titleLabel!)
        contentView.addSubview(cardNumberTextField)
        contentView.addSubview(cardNumberSeparatorView)
        contentView.addSubview(expirationMonthTextField)
        contentView.addSubview(expirationMonthYearSeparatorLabel)
        contentView.addSubview(expirationYearTextField)
        contentView.addSubview(cvcTextField)
        
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        
        cardNumberTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        expirationMonthTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        expirationYearTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        cvcTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
        expirationMonthTextField.inputView = pickerMonth
        expirationYearTextField.inputView = pickerYear
        
        pickerMonth.delegate = self
        pickerMonth.dataSource = self
        pickerYear.delegate = self
        pickerYear.dataSource = self
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        if let title = row.title {
            cardNumberTextField.textAlignment = .Left
            cardNumberTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
            
            expirationMonthTextField.textAlignment = .Left
            expirationMonthTextField.clearButtonMode = .Never
            
            expirationYearTextField.textAlignment = .Left
            expirationYearTextField.clearButtonMode = .Never
            
            cvcTextField.textAlignment = .Right
            cvcTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
        } else {
            cardNumberTextField.textAlignment = .Left
            cardNumberTextField.clearButtonMode = .WhileEditing
            
            expirationMonthTextField.textAlignment = .Left
            expirationMonthTextField.clearButtonMode = .Never
            
            expirationYearTextField.textAlignment = .Left
            expirationYearTextField.clearButtonMode = .Never
            
            cvcTextField.textAlignment = .Right
            cvcTextField.clearButtonMode = .WhileEditing
        }
        
        cardNumberTextField.delegate = self
        cardNumberTextField.text = row.value?.cardNumber
        cardNumberTextField.enabled = !row.isDisabled
        cardNumberTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        cardNumberTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        cardNumberTextField.autocorrectionType = .No
        cardNumberTextField.autocapitalizationType = .None
        cardNumberTextField.keyboardType = .NumberPad
        cardNumberTextField.showsCardLogo = true
        
        expirationMonthTextField.delegate = self
        expirationMonthTextField.text = row.value?.expirationMonth
        expirationMonthTextField.enabled = !row.isDisabled
        expirationMonthTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        expirationMonthTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        expirationMonthTextField.autocorrectionType = .No
        expirationMonthTextField.autocapitalizationType = .None
        expirationMonthTextField.keyboardType = .NumberPad
        expirationMonthTextField.tintColor = UIColor.clearColor(); // This will hide the blinking cursor in the textfield
        expirationMonthTextField.ccMaxLength = 2
        
        expirationYearTextField.delegate = self
        expirationYearTextField.text = row.value?.expirationYear
        expirationYearTextField.enabled = !row.isDisabled
        expirationYearTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        expirationYearTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        expirationYearTextField.autocorrectionType = .No
        expirationYearTextField.autocapitalizationType = .None
        expirationYearTextField.keyboardType = .NumberPad
        expirationYearTextField.tintColor = UIColor.clearColor(); // This will hide the blinking cursor in the textfield
        expirationYearTextField.ccMaxLength = 4
        
        cvcTextField.delegate = self
        cvcTextField.text = row.value?.cvc
        cvcTextField.enabled = !row.isDisabled
        cvcTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        cvcTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        cvcTextField.autocorrectionType = .No
        cvcTextField.autocapitalizationType = .None
        cvcTextField.keyboardType = .NumberPad
        cvcTextField.ccMaxLength = 3
        
        if let rowConformance = row as? CreditCardRowConformance {
            if let placeholder = rowConformance.cardNumberPlaceholder {
                cardNumberTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    cardNumberTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.expirationMonthPlaceholder {
                expirationMonthTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    expirationMonthTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.expirationYearPlaceholder {
                expirationYearTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    expirationYearTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.cvcPlaceholder {
                cvcTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    cvcTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
        }
        
        pickerMonth.reloadAllComponents()
        if let selectedValue = row.value?.expirationMonth, let index = months.indexOf(selectedValue) {
            pickerMonth.selectRow(index + 1, inComponent: 0, animated: true)
        }
        pickerYear.reloadAllComponents()
        if let selectedValue = row.value?.expirationYear, let index = years.indexOf(selectedValue) {
            pickerYear.selectRow(index + 1, inComponent: 0, animated: true)
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && (
            cardNumberTextField.canBecomeFirstResponder() ||
                expirationMonthTextField.canBecomeFirstResponder() ||
                expirationYearTextField.canBecomeFirstResponder() ||
                cvcTextField.canBecomeFirstResponder()
        )
    }
    
    public override func cellBecomeFirstResponder(direction: Direction) -> Bool {
        return direction == .Down ? cardNumberTextField.becomeFirstResponder() : cvcTextField.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return cardNumberTextField.resignFirstResponder()
            && expirationMonthTextField.resignFirstResponder()
            && expirationYearTextField.resignFirstResponder()
            && cvcTextField.resignFirstResponder()
    }
    
    override public var inputAccessoryView: UIView? {
        
        if let v = formViewController()?.inputAccessoryViewForRow(row) as? NavigationAccessoryView {
            if cardNumberTextField.isFirstResponder() {
                v.nextButton.enabled = true
                v.nextButton.target = self
                v.nextButton.action = "internalNavigationAction:"
            } else if expirationMonthTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = "internalNavigationAction:"
                v.nextButton.target = self
                v.nextButton.action = "internalNavigationAction:"
                v.previousButton.enabled = true
                v.nextButton.enabled = true
            } else if expirationYearTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = "internalNavigationAction:"
                v.nextButton.target = self
                v.nextButton.action = "internalNavigationAction:"
                v.previousButton.enabled = true
                v.nextButton.enabled = true
            } else if cvcTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = "internalNavigationAction:"
                v.previousButton.enabled = true
            }
            return v
        }
        return super.inputAccessoryView
    }
    
    func internalNavigationAction(sender: UIBarButtonItem) {
        guard let inputAccesoryView = inputAccessoryView as? NavigationAccessoryView else {
            return
        }
        
        if cardNumberTextField.isFirstResponder() {
            sender == inputAccesoryView.previousButton ? cardNumberTextField.becomeFirstResponder() : expirationMonthTextField.becomeFirstResponder()
        } else if expirationMonthTextField.isFirstResponder() {
            sender == inputAccesoryView.previousButton ? cardNumberTextField.becomeFirstResponder() : expirationYearTextField.becomeFirstResponder()
        } else if expirationYearTextField.isFirstResponder() {
            sender == inputAccesoryView.previousButton ? expirationMonthTextField.becomeFirstResponder() : cvcTextField.becomeFirstResponder()
        } else if cvcTextField.isFirstResponder() {
            expirationYearTextField.becomeFirstResponder()
        }
    }
    
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] where ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    // Mark: Helpers
    public override func updateConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        
        let cellHeight: CGFloat = self.height!()
        let cellPadding: CGFloat = 4.0
        let textFieldMargin: CGFloat = 4.0
        let textFieldHeight: CGFloat = (cellHeight - 2.0 * cellPadding - 2.0 * textFieldMargin) / 2.0
        let expirationMonthTextFieldWidth: CGFloat = 30.0
        let expirationYearTextFieldWidth: CGFloat = 50.0
        let expirationMonthYearLabelWidth: CGFloat = 15.0
        let separatorViewHeight = 0.45
        
        var views: [String:AnyObject] = [
            "cardNumberTextField": cardNumberTextField,
            "cardNumberSeparatorView": cardNumberSeparatorView,
            "expirationMonthTextField": expirationMonthTextField,
            "expirationMonthYearSeparatorLabel": expirationMonthYearSeparatorLabel,
            "expirationYearTextField": expirationYearTextField,
            "cvcTextField": cvcTextField
        ]
        
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationMonthTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationMonthYearSeparatorLabel(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationYearTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[cvcTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        
        if let label = titleLabel, let text = label.text where !text.isEmpty {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[titleLabel]-\(cellPadding)-|", options: [], metrics: nil, views: ["titleLabel": label])
            dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
            } else {
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
                
            }
        } else {
            
            if let titleLabel = titleLabel, let text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
                
                let multiplier = (row as? CreditCardRowConformance)?.dataSectionWidthPercentage ?? 0.3
                dynamicConstraints.append(NSLayoutConstraint(item: cardNumberTextField, attribute: .Width, relatedBy: (row as? CreditCardRowConformance)?.dataSectionWidthPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: multiplier, constant: 0.0))
            } else {
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[cardNumberTextField]-|", options: .AlignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[cardNumberSeparatorView]-|", options: .AlignAllLeft, metrics: nil, views: views)
            }
        }
        
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    public func textFieldDidChange(textField: UITextField) {
        guard let textValue = textField.text else {
            switch (textField) {
            case cardNumberTextField:
                row.value?.cardNumber = nil
                
            case expirationMonthTextField:
                row.value?.expirationMonth = nil
            case expirationYearTextField:
                row.value?.expirationYear = nil
                
            case cvcTextField:
                row.value?.cvc = nil
                
            default:
                break
            }
            return
        }
        
        guard !textValue.isEmpty else {
            switch (textField) {
            case cardNumberTextField:
                row.value?.cardNumber = nil
            case expirationMonthTextField:
                row.value?.expirationMonth = nil
            case expirationYearTextField:
                row.value?.expirationYear = nil
            case cvcTextField:
                row.value?.cvc = nil
            default:
                break
            }
            return
        }
        
        switch (textField) {
        case cardNumberTextField:
            row.value?.cardNumber = textValue
        case expirationMonthTextField:
            row.value?.expirationMonth = textValue
        case expirationYearTextField:
            row.value?.expirationYear = textValue
        case cvcTextField:
            row.value?.cvc = textValue
        default:
            break
        }
    }
    
    //MARK: TextFieldDelegate
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == expirationMonthTextField
            || textField == expirationYearTextField {
            return false;
        }
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    // MARK: Pickers
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerMonth {
            return self.months.count + 1 ?? 0
        } else {
            return self.years.count + 1 ?? 0
        }
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Select..."
        } else {
            if pickerView == pickerMonth {
                return "\(self.months[row - 1]) - \(self.monthsName[row - 1])"
            } else {
                return self.years[row - 1]
            }
        }
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerMonth {
            //            self.row.value?.expirationMonth = self.months[row]
            expirationMonthTextField.text = self.months[row - 1]
        } else {
            //            self.row.value?.expirationYear = self.years[row]
            expirationYearTextField.text = self.years[row - 1]
        }
    }
}


public class _CreditCardRow<T:Equatable, Cell:CellType where Cell: BaseCell, Cell: TypedCellType, Cell: CreditCardCellConformance, Cell.Value == T>: Row<T, Cell>, CreditCardRowConformance, KeyboardReturnHandler {
    
    /// Configuration for the keyboardReturnType of this row
    public var keyboardReturnType: KeyboardReturnTypeConfiguration?
    
    /// The percentage of the cell that should be occupied by the postal address
    public var dataSectionWidthPercentage: CGFloat?
    
    /// The textColor for the textField's placeholder
    public var placeholderColor: UIColor?
    
    /// The placeholder for the cardNumber textField
    public var cardNumberPlaceholder: String?
    
    /// The placeholder for the zip textField
    public var expirationMonthPlaceholder: String?
    
    /// The placeholder for the expirationYear textField
    public var expirationYearPlaceholder: String?
    
    /// The placeholder for the cvc textField
    public var cvcPlaceholder: String?
    
    /// A formatter to be used to format the user's input for cardNumber
    public var cardNumberFormatter: NSFormatter?
    
    /// If the formatter should be used while the user is editing the cardNumber.
    public var cardNumberUseFormatterDuringInput: Bool
    
    
    public required init(tag: String?) {
        cardNumberUseFormatterDuringInput = false
        
        super.init(tag: tag)
    }
}


/// A CreditCard valued row where the user can enter a postal address.

public final class CreditCardRow: _CreditCardRow<CreditCard, CreditCardCell<CreditCard>>, RowType {
    public required init(tag: String? = nil) {
        super.init(tag: tag)
        /*onCellHighlight { cell, row  in
         let color = cell.textLabel?.textColor
         row.onCellUnHighlight { cell, _ in
         cell.textLabel?.textColor = color
         }
         cell.textLabel?.textColor = cell.tintColor
         }*/
    }
}


// Extension that adds the maxLenght to a UITextField

private var maxLengthDictionary = [UITextField:Int]()

extension UITextField {

    @IBInspectable var ccMaxLength: Int {
        get {
            if let length = maxLengthDictionary[self] {
                return length
            } else {
                return Int.max
            }
        }
        set {
            maxLengthDictionary[self] = newValue
            addTarget(self, action: "checkMaxLength:", forControlEvents: UIControlEvents.EditingChanged)
        }
    }

    func checkMaxLength(sender: UITextField) {
        let newText = sender.text
        if newText?.characters.count > ccMaxLength {
            let cursorPosition = selectedTextRange
            text = (newText! as NSString).substringWithRange(NSRange(location: 0, length: ccMaxLength))
            selectedTextRange = cursorPosition
        }
    }
}