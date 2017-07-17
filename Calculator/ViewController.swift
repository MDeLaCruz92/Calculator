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
    @IBOutlet weak var memory: UILabel!
    
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
            history.text = brain.evaluate().isPending ? brain.evaluate().description + " ..." : brain.evaluate().description + " ="
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
            if brain.evaluate().isPending && !currentHistory.contains("=") && !currentHistory.contains("...") {
                history.text = currentHistory + " " + mathSymbol + " ..."
            }
        }
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
    // most likely got to work on task 3 and 4 to fix this better and make it accept the variables properly
    @IBAction func storeMemory(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        let currentHistory = history.text!
        memory.text = "M : \(brain.evaluate().result ?? 0)"
        if let memorySymbol = sender.currentTitle {
            if brain.resultIsPending && !currentHistory.contains("=") {
                history.text = currentHistory + " " + memorySymbol + " ..."
            }
        }
    }
    
    @IBAction func callsToMemory(_ sender: UIButton) {
        // evaluate in your Model with a Dictionary which has a single entry whose key is M and whose value is the current value of
        // the display, and then updates the display to show the result that comes back from evaluate
    }
    
    @IBAction func clearButton(_ sender: UIButton) { // buggy
        brain = CalculatorBrain()
        brain.clearState()
        display.text = " "
        history.text = " "
        memory.text = "M : 0"
        userIsInTheMiddleOfTyping = false
    }
    
    // Auto Layout Lecture
    private func showSizeClasses() {
        if !userIsInTheMiddleOfTyping {
            display.textAlignment = .center
            display.text = "width " + traitCollection.horizontalSizeClass.description + " height " + traitCollection.verticalSizeClass.description
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { coordinate in
            self.showSizeClasses()
        }, completion: nil)
    }
    
}

// Auto Layout Lecture
extension UIUserInterfaceSizeClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compact: return "Compact"
        case .regular: return "Regular"
        case .unspecified: return "??"
        }
    }
}
