//
//  TodayViewController.swift
//  CalculatorCore
//
//  Created by Andrew Dhan on 10/22/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import UIKit
import NotificationCenter
import RPN

class TodayViewController: UIViewController, NCWidgetProviding {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize

//            stackViewCollapsed.isUserInteractionEnabled = true
            stackViewCollapsed.isHidden = false
//            stackViewExpanded.isUserInteractionEnabled = false
            stackViewExpanded.isHidden = true
        case .expanded:
            preferredContentSize = CGSize(width: maxSize.width, height: 300)
//            stackViewExpanded.isUserInteractionEnabled = true
            stackViewExpanded.isHidden = false
//            stackViewCollapsed.isUserInteractionEnabled = false
            stackViewCollapsed.isHidden = true
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        completionHandler(NCUpdateResult.newData)
    }
    @IBOutlet var collapsedTextField: UITextField!
    
    @IBOutlet weak var expandedTextField: UITextField!
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumIntegerDigits = 20
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 20
        return formatter
    }()
    
    private var calculator = Calculator() {
        didSet {
            if let value = calculator.topValue {
                valueString = numberFormatter.string(from: value as NSNumber)
            } else {
                valueString = ""
            }
        }
    }
    
    private var digitAccumulator = DigitAccumulator() {
        didSet {
            if let value = digitAccumulator.value() {
                valueString = numberFormatter.string(from: value as NSNumber)
            } else {
                valueString = ""
            }
        }
    }
    
    @IBAction func numberButtonTapped(_ sender: UIButton) {
        try? digitAccumulator.add(digit: .number(sender.tag))
    }
    
    @IBAction func decimalButtonTapped(_ sender: UIButton) {
        try? digitAccumulator.add(digit: .decimalPoint)
    }
    
    @IBAction func returnButtonTapped(_ sender: UIButton) {
        if let value = digitAccumulator.value() {
            calculator.push(number: value)
        }
        digitAccumulator.clear()
    }
    
    @IBAction func divideButtonTapped(_ sender: UIButton) {
        returnButtonTapped(sender)
        calculator.push(operator: .divide)
    }
    
    @IBAction func multiplyButtonTapped(_ sender: UIButton) {
        returnButtonTapped(sender)
        calculator.push(operator: .multiply)
    }
    
    @IBAction func subtractButtonTapped(_ sender: UIButton) {
        returnButtonTapped(sender)
        calculator.push(operator: .subtract)
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        returnButtonTapped(sender)
        calculator.push(operator: .add)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        calculator.clear()
        digitAccumulator.clear()
        return true
    }
    
    @IBAction func copyResult(_ sender: UIButton) {
        guard let value = valueString else {return}
        pasteBoard.string = value
        if let saved = pasteBoard.string{
            print("\(saved) is copied to your clipboard ")
        }
    }
    
    @IBOutlet var stackViewCollapsed: UIStackView!
    @IBOutlet weak var stackViewExpanded: UIStackView!
    let pasteBoard = UIPasteboard.general
    private var valueString:String?{
        didSet{
            expandedTextField.text = valueString
            collapsedTextField.text = valueString
        }
    }
}
