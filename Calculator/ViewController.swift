//
//  ViewController.swift
//  Calculator
//
//  Created by Michael De La Cruz on 4/1/17.
//  Copyright © 2017 Michael De La Cruz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let currentHistory = history.text!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display!.text = textCurrentlyInDisplay + digit
            if textCurrentlyInDisplay.contains(".") && digit == "." {
                display!.text = textCurrentlyInDisplay
                history!.text = currentHistory
            } else if !currentHistory.contains("=") && !currentHistory.contains("...") {
                history!.text = currentHistory + digit
            }
        } else {
            display!.text = digit == "." ? "0." : digit
//            history!.text = brain.resultIsPending ? digit + " ..." : digit
            if !currentHistory.contains("=") && !currentHistory.contains("...") {
                history!.text = currentHistory + " " + display.text!
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)! // crashes here often when I use clear, and type in digits/operands
        }
        set {
            display.text = String(newValue)
            history.text = brain.resultIsPending ? brain.description! + " ..." : brain.description! + " ="
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
            let currentHistory = history.text!
            if brain.resultIsPending && !currentHistory.contains("=") && !currentHistory.contains("...") {
                history!.text = currentHistory + " " + mathSymbol + " ..."
            }
        }
        if let result = brain.result {
            displayValue = result
        }
    }
    
    @IBAction func clearButton(_ sender: UIButton) { // buggy
        brain = CalculatorBrain()
        userIsInTheMiddleOfTyping = false
        display!.text = " "
        history!.text = " "
    }
    
}

