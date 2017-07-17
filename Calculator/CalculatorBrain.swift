//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael De La Cruz on 4/1/17.
//  Copyright © 2017 Michael De La Cruz. All rights reserved.
//

import Foundation

//func changeSign(operand: Double) -> Double {
//  return -operand
//}

//func multiply(op1: Double, op2: Double) -> Double {
//  return op1 * op2
//}

struct CalculatorBrain {
    
    private var stack: Array<Element>?    // added
    
    private enum Element {                // added
        case operand(Double)
        case name(String)
        case operation(String)
    }
    
    private enum Operation {
        case constant(Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi, "π"),
        "e" : Operation.constant(M_E, "e"),
        "√" : Operation.unaryOperation(sqrt, {"√(\($0))"}),
        "sin": Operation.unaryOperation(sin, {"sin(\($0))"}),
        "cos" : Operation.unaryOperation(cos, {"cos(\($0))"}),
        "tan": Operation.unaryOperation(tan, {"tan(\($0))"}),
        "±" : Operation.unaryOperation({ -$0 }, {"-(\($0))"}),
        "x²": Operation.unaryOperation({ $0 * $0 }, {"x²(\($0))"}),
        "×" : Operation.binaryOperation({ $0 * $1 }, {"\( $0 + " × " + $1 )"}),
        "÷" : Operation.binaryOperation({ $0 / $1 }, {"\( $0 + " ÷ " + $1 )"}),
        "+" : Operation.binaryOperation({ $0 + $1 }, {"\( $0 + " + " + $1 )"}),
        "−" : Operation.binaryOperation({ $0 - $1 }, {"\( $0 + " - " + $1 )"}),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value, let description):
                accumulator = value
                representation = description
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    representation = description(representation!)
                }
            case .binaryOperation(let function, let description):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, stringFunction: description, firstOperand: accumulator!, stringOperand: representation!)
                    accumulator = nil
                    representation = ""
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            representation = pendingBinaryOperation!.performDescription(with: representation!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let stringFunction: (String, String) -> String
        let firstOperand: Double
        let stringOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String  {
            return stringFunction(stringOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        representation = "\(operand)"
    }
    
    mutating func setOperand(variable name: String) {
        stack?.append(Element.name(name))
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        var description: String? {
            return resultIsPending ? pendingBinaryOperation?.performDescription(with: representation!) : representation ?? ""
        }
        
        var result: Double? {
            return accumulator
        }
        
        return (result: result ?? 0, isPending: resultIsPending, description: description!)
    }
    
    mutating func clearState() {
        pendingBinaryOperation = nil
        accumulator = nil
        representation = ""
    }
    
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    var description: String? {
        return evaluate().description
    }
    
    var result: Double? {
        return evaluate().result
    }
    
//    @available (*, unavailable, message: "Evaluate method overrides accumalator's purpose")
    private var accumulator: Double?
//    @available (*, unavailable, message: "Evaluate method overrides representation's purpose")
    private var representation: String?
    
}

/*
 
 
*/
