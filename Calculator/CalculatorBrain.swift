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
    
    private var stack = Array<Element>()    // added
    
    private enum Element {                // added
        case operand(Double)
        case variable(String)
        case operation(String)
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
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
        stack.append(Element.operation(symbol))
    }
    
    mutating func setOperand(_ operand: Double) {
        stack.append(Element.operand(operand))
    }
    
    mutating func setOperand(variable name: String) {
        stack.append(Element.variable(name))
    }
    
    mutating func undo() {
        if !stack.isEmpty {
            stack.removeLast()
        }
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        
        var accumulator: (Double, String)?
        var pendingBinaryOperation: PendingBinaryOperation?
        
        struct PendingBinaryOperation {
            let symbol: String
            let function: (Double, Double) -> Double
            let description: (String, String) -> String
            let firstOperand: (Double, String)
            
            func perform(with secondOperand: (Double, String)) -> (Double, String) {
                return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
            }
        }
        
        func performPendingBinaryOperation() {
            if pendingBinaryOperation != nil && accumulator != nil {
                accumulator = pendingBinaryOperation!.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
        
        var resultIsPending: Bool {
            return pendingBinaryOperation != nil
        }
        
        var description: String? {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? "")
            } else {
                return accumulator?.1
            }
        }
        
        var result: Double? {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
        
        // Loop over the stack. Set the accumulator for operands & variables. Use the old code of performOperation for the operations
        for element in stack {
            switch element {
            case .operand(let value):
                accumulator = (value, "\(value)")
            case .operation(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value):
                        accumulator = (value, symbol)
                    case .unaryOperation(let function, let description):
                        if accumulator != nil {
                            accumulator = (function(accumulator!.0), description(accumulator!.1))
                        }
                    case .binaryOperation(let function, let description):
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(symbol: symbol, function: function, description: description, firstOperand: accumulator!)
                            accumulator = nil
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let symbol):
                if let value = variables?[symbol] {
                    accumulator = (value, symbol)
                } else {
                    accumulator = (0, symbol)
                }
            }
        }
        
        return (result: result ?? 0, isPending: resultIsPending, description: description!)
    }
    
    mutating func clearState() {
//        pendingBinaryOperation = nil
//        accumulator = nil
//        representation = ""
    }
    
    @available (*, unavailable, message: "No longer needed...")
    var resultIsPending: Bool {
        return evaluate().isPending
    }
    @available (*, unavailable, message: "No longer needed...")
    var description: String? {
        return evaluate().description
    }
    @available (*, unavailable, message: "No longer needed...")
    var result: Double? {
        return evaluate().result
    }
    
}

