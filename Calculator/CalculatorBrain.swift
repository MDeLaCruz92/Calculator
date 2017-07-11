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
    
    private var accumulator: Double?
    private var representation: String?
    
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
        "x2": Operation.unaryOperation({ $0 * $0 }, {"\($0)"}),
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
                    representation = " "
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
        let stringFunction: (String, String) -> String // added
        let firstOperand: Double
        let stringOperand: String // added
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func performDescription(with secondOperand: String) -> String  { // added
            return stringFunction(stringOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        representation = "\(operand)"
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    var description: String? { // CHANGING TO OPTIONAL
        return resultIsPending ? pendingBinaryOperation?.performDescription(with: representation!) : representation ?? " "
    }
    
    var result: Double? {
        return accumulator
    }
    
}

/*
 
 
*/
