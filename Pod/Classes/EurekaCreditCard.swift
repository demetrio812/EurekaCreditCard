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
    separatorView.backgroundColor = .lightGray
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
    textLabel?.setContentHuggingPriority(500, for: .horizontal)
    textLabel?.setContentCompressionResistancePriority(1000, for: .horizontal)
    return textLabel
  }
  
  private var dynamicConstraints = [NSLayoutConstraint]()
  
  public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    cardNumberTextField.delegate = nil
    cardNumberTextField.removeTarget(self, action: nil, for: .allEvents)
    expirationMonthTextField.delegate = nil
    expirationMonthTextField.removeTarget(self, action: nil, for: .allEvents)
    expirationYearTextField.delegate = nil
    expirationYearTextField.removeTarget(self, action: nil, for: .allEvents)
    cvcTextField.delegate = nil
    cvcTextField.removeTarget(self, action: nil, for: .allEvents)
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
    selectionStyle = .none
    
    let dateFormatter: DateFormatter = DateFormatter()
    monthsName = dateFormatter.shortMonthSymbols
    
    for myMonthInt in 1 ... 12 {
      months.append(String(format: "%02d", myMonthInt))
    }
    let currentYear = NSCalendar.current.component(.year, from: NSDate() as Date)
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
    
    titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
    imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
    
    cardNumberTextField.addTarget(self, action: #selector(CreditCardCell.textFieldDidChange(_:)), for: .editingChanged)
    expirationMonthTextField.addTarget(self, action: #selector(CreditCardCell.textFieldDidChange(_:)), for: .editingChanged)
    expirationYearTextField.addTarget(self, action: #selector(CreditCardCell.textFieldDidChange(_:)), for: .editingChanged)
    cvcTextField.addTarget(self, action: #selector(CreditCardCell.textFieldDidChange(_:)), for: .editingChanged)
    
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
      cardNumberTextField.textAlignment = .left
      cardNumberTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
      
      expirationMonthTextField.textAlignment = .left
      expirationMonthTextField.clearButtonMode = .never
      
      expirationYearTextField.textAlignment = .left
      expirationYearTextField.clearButtonMode = .never
      
      cvcTextField.textAlignment = .right
      cvcTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
    } else {
      cardNumberTextField.textAlignment = .left
      cardNumberTextField.clearButtonMode = .whileEditing
      
      expirationMonthTextField.textAlignment = .left
      expirationMonthTextField.clearButtonMode = .never
      
      expirationYearTextField.textAlignment = .left
      expirationYearTextField.clearButtonMode = .never
      
      cvcTextField.textAlignment = .right
      cvcTextField.clearButtonMode = .whileEditing
    }
    
    cardNumberTextField.delegate = self
    cardNumberTextField.text = row.value?.cardNumber
    cardNumberTextField.isEnabled = !row.isDisabled
    cardNumberTextField.textColor = row.isDisabled ? .gray : .black
    cardNumberTextField.font = .preferredFont(forTextStyle: .body)
    cardNumberTextField.autocorrectionType = .no
    cardNumberTextField.autocapitalizationType = .none
    cardNumberTextField.keyboardType = .numberPad
    cardNumberTextField.showsCardLogo = true
    
    expirationMonthTextField.delegate = self
    expirationMonthTextField.text = row.value?.expirationMonth
    expirationMonthTextField.isEnabled = !row.isDisabled
    expirationMonthTextField.textColor = row.isDisabled ? .gray : .black
    expirationMonthTextField.font = .preferredFont(forTextStyle: .body)
    expirationMonthTextField.autocorrectionType = .no
    expirationMonthTextField.autocapitalizationType = .none
    expirationMonthTextField.keyboardType = .numberPad
    expirationMonthTextField.tintColor = .clear // This will hide the blinking cursor in the textfield
    expirationMonthTextField.ccMaxLength = 2
    
    expirationYearTextField.delegate = self
    expirationYearTextField.text = row.value?.expirationYear
    expirationYearTextField.isEnabled = !row.isDisabled
    expirationYearTextField.textColor = row.isDisabled ? .gray : .black
    expirationYearTextField.font = .preferredFont(forTextStyle: .body)
    expirationYearTextField.autocorrectionType = .no
    expirationYearTextField.autocapitalizationType = .none
    expirationYearTextField.keyboardType = .numberPad
    expirationYearTextField.tintColor = .clear // This will hide the blinking cursor in the textfield
    expirationYearTextField.ccMaxLength = 4
    
    cvcTextField.delegate = self
    cvcTextField.text = row.value?.cvc
    cvcTextField.isEnabled = !row.isDisabled
    cvcTextField.textColor = row.isDisabled ? .gray : .black
    cvcTextField.font = .preferredFont(forTextStyle: .body)
    cvcTextField.autocorrectionType = .no
    cvcTextField.autocapitalizationType = .none
    cvcTextField.keyboardType = .numberPad
    cvcTextField.ccMaxLength = 3
    cvcTextField.isSecureTextEntry = true
    
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
    if let selectedValue = row.value?.expirationMonth, let index = months.index(of: selectedValue) {
      pickerMonth.selectRow(index + 1, inComponent: 0, animated: true)
    }
    pickerYear.reloadAllComponents()
    if let selectedValue = row.value?.expirationYear, let index = years.index(of: selectedValue) {
      pickerYear.selectRow(index + 1, inComponent: 0, animated: true)
    }
  }
  
  public override func cellCanBecomeFirstResponder() -> Bool {
    return !row.isDisabled && (
      cardNumberTextField.canBecomeFirstResponder ||
        expirationMonthTextField.canBecomeFirstResponder ||
        expirationYearTextField.canBecomeFirstResponder ||
        cvcTextField.canBecomeFirstResponder
    )
  }
  
  public override func cellBecomeFirstResponder(_ direction: Direction) -> Bool {
    return direction == .down ? cardNumberTextField.becomeFirstResponder() : cvcTextField.becomeFirstResponder()
  }
  
  public override func cellResignFirstResponder() -> Bool {
    return cardNumberTextField.resignFirstResponder()
      && expirationMonthTextField.resignFirstResponder()
      && expirationYearTextField.resignFirstResponder()
      && cvcTextField.resignFirstResponder()
  }
  
  override public var inputAccessoryView: UIView? {
    
    if let v = formViewController()?.inputAccessoryViewForRow(row) as? NavigationAccessoryView {
      if cardNumberTextField.isFirstResponder {
        v.nextButton.isEnabled = true
        v.nextButton.target = self
        v.nextButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
      } else if expirationMonthTextField.isFirstResponder {
        v.previousButton.target = self
        v.previousButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
        v.nextButton.target = self
        v.nextButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
        v.previousButton.isEnabled = true
        v.nextButton.isEnabled = true
      } else if expirationYearTextField.isFirstResponder {
        v.previousButton.target = self
        v.previousButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
        v.nextButton.target = self
        v.nextButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
        v.previousButton.isEnabled = true
        v.nextButton.isEnabled = true
      } else if cvcTextField.isFirstResponder {
        v.previousButton.target = self
        v.previousButton.action = #selector(CreditCardCell.internalNavigationAction(_:))
        v.previousButton.isEnabled = true
      }
      return v
    }
    return super.inputAccessoryView
  }
  
  func internalNavigationAction(_ sender: UIBarButtonItem) {
    guard let inputAccesoryView = inputAccessoryView as? NavigationAccessoryView else {
      return
    }
    
    if cardNumberTextField.isFirstResponder {
      sender == inputAccesoryView.previousButton ? cardNumberTextField.becomeFirstResponder() : expirationMonthTextField.becomeFirstResponder()
    } else if expirationMonthTextField.isFirstResponder {
      sender == inputAccesoryView.previousButton ? cardNumberTextField.becomeFirstResponder() : expirationYearTextField.becomeFirstResponder()
    } else if expirationYearTextField.isFirstResponder {
      sender == inputAccesoryView.previousButton ? expirationMonthTextField.becomeFirstResponder() : cvcTextField.becomeFirstResponder()
    } else if cvcTextField.isFirstResponder {
      expirationYearTextField.becomeFirstResponder()
    }
  }
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if let obj = object as? UILabel, let keyPathValue = keyPath, let changeType = change?[.kindKey] as? NSNumber , ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.uintValue == NSKeyValueChange.setting.rawValue {
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
    
    dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationMonthTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
    dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationMonthYearSeparatorLabel(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
    dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[expirationYearTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
    dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[cardNumberTextField(\(textFieldHeight))]-\(textFieldMargin)-[cardNumberSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[cvcTextField(\(textFieldHeight))]-\(cellPadding)-|", options: [], metrics: nil, views: views)
    
    if let label = titleLabel, let text = label.text , !text.isEmpty {
      dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[titleLabel]-\(cellPadding)-|", options: [], metrics: nil, views: ["titleLabel": label])
      dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    if let imageView = imageView, let _ = imageView.image {
      views["imageView"] = imageView
      if let titleLabel = titleLabel, let text = titleLabel.text , !text.isEmpty {
        views["label"] = titleLabel
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
        
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
      } else {
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
        
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
        
      }
    } else {
      
      if let titleLabel = titleLabel, let text = titleLabel.text , !text.isEmpty {
        views["label"] = titleLabel
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[cardNumberTextField]-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
        
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[cardNumberSeparatorView]-|", options: [], metrics: nil, views: views)
        
        let multiplier = (row as? CreditCardRowConformance)?.dataSectionWidthPercentage ?? 0.3
        dynamicConstraints.append(NSLayoutConstraint(item: cardNumberTextField, attribute: .width, relatedBy: (row as? CreditCardRowConformance)?.dataSectionWidthPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: multiplier, constant: 0.0))
      } else {
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cardNumberTextField]-|", options: .alignAllLeft, metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[expirationMonthTextField(\(expirationMonthTextFieldWidth))]-\(textFieldMargin * 2.0)-[expirationMonthYearSeparatorLabel(\(expirationMonthYearLabelWidth))]-[expirationYearTextField(\(expirationYearTextFieldWidth))]-\(textFieldMargin * 2.0)-[cvcTextField]-|", options: [], metrics: nil, views: views)
        
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cardNumberSeparatorView]-|", options: .alignAllLeft, metrics: nil, views: views)
      }
    }
    
    contentView.addConstraints(dynamicConstraints)
    super.updateConstraints()
  }
  
  public func textFieldDidChange(_ textField: UITextField) {
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
  
  public func textFieldDidBeginEditing(_ textField: UITextField) {
    formViewController()?.beginEditing(self)
    formViewController()?.textInputDidBeginEditing(textField, cell: self)
  }
  
  public func textFieldDidEndEditing(_ textField: UITextField) {
    formViewController()?.endEditing(self)
    formViewController()?.textInputDidEndEditing(textField, cell: self)
    textFieldDidChange(textField)
  }
  
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
  }
  
  
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == expirationMonthTextField
      || textField == expirationYearTextField {
      return false;
    }
    return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
  }
  
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
  }
  
  public func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
  }
  
  public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
  }
  
  // MARK: Pickers
  public func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if pickerView == pickerMonth {
      return self.months.count + 1
    } else {
      return self.years.count + 1
    }
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == pickerMonth {
      if row > 0 {
        expirationMonthTextField.text = self.months[row - 1]
        self.row.value?.expirationMonth = self.months[row - 1]
      } else {
        expirationMonthTextField.text = nil
      }
      
    } else {
      if row > 0 {
        expirationYearTextField.text = self.years[row - 1]
        self.row.value?.expirationYear = self.years[row - 1]
      } else {
        expirationYearTextField.text = nil
      }
      
    }
  }
}


public class _CreditCardRow<T:Equatable, Cell:CellType>: Row<Cell>, CreditCardRowConformance, KeyboardReturnHandler where Cell: BaseCell, Cell: TypedCellType, Cell: CreditCardCellConformance, Cell.Value == T {
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
  public var cardNumberFormatter: Formatter?
  
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
      addTarget(self, action: #selector(UITextField.checkMaxLength(_:)), for: UIControlEvents.editingChanged)
    }
  }
  
  func checkMaxLength(_ sender: UITextField) {
    let newText = sender.text
    if (newText?.characters.count)! > ccMaxLength {
      let cursorPosition = selectedTextRange
      text = (newText! as NSString).substring(with: NSRange(location: 0, length: ccMaxLength))
      selectedTextRange = cursorPosition
    }
  }
}
