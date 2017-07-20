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
    
    private var userIsInTheMiddleOfTyping = false
    
    private var variables = Dictionary<String,Double>() {
        didSet {
            memory.text = variables.flatMap{$0+":\($1)"}.joined(separator: ",")
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
            if !textCurrentlyInDisplay.contains(".") || "." != digit {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display!.text = "." == digit ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    private func evaluateExpression() {
        let evaluation = brain.evaluate(using: variables)
        if let result = evaluation.result {
            displayValue = result
        }
        
        if "" != evaluation.description {
            history.text = evaluation.description + (evaluation.isPending ? "..." : " =")
        } else {
            history.text = " "
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        evaluateExpression()
    }
    
    @IBAction func storeToMemory(_ sender: UIButton) {
        variables["M"] = displayValue
        userIsInTheMiddleOfTyping = false
        evaluateExpression()
    }
    
    
    @IBAction func onMemory(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        userIsInTheMiddleOfTyping = false
        evaluateExpression()
    }
    
    @IBAction func clearButton(_ sender: UIButton) { // buggy
        brain = CalculatorBrain()
        displayValue = 0
        history.text = " "
        userIsInTheMiddleOfTyping = false
        variables = Dictionary<String,Double>()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping, var text = display.text {
            text.remove(at: text.index(before: text.endIndex))
            if text.isEmpty {
                text = "0"
                userIsInTheMiddleOfTyping = false
            }
            display.text = text
        } else {
            brain.undo()
            evaluateExpression()
        }
    }
}
////////////// Auto Layout Lecture /////////////////////
//    private func showSizeClasses() {
//        if !userIsInTheMiddleOfTyping {
//            display.textAlignment = .center
//            display.text = "width " + traitCollection.horizontalSizeClass.description + " height " + traitCollection.verticalSizeClass.description
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        showSizeClasses()
//    }
//
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: { coordinate in
//            self.showSizeClasses()
//        }, completion: nil)
//    }

//////////// Auto Layout Lecture //////////////
//extension UIUserInterfaceSizeClass: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .compact: return "Compact"
//        case .regular: return "Regular"
//        case .unspecified: return "??"
//        }
//    }
//}

