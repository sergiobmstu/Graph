//
//  ViewController.swift
//  Graph
//
//  Created by Sergey on 23.02.2018.
//  Copyright © 2018 Sergey Kochetov. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController {

    @IBOutlet weak var formulaTextField: UITextField!
    @IBOutlet weak var graphView: GraphView!
    
    
    @IBAction func drow(_ sender: UIButton) {
        guard let input = formulaTextField.text, formulaTextField.text != "" else
        {
            showAlert(message: "Enter the function")
            return
        }
        if isValidFunc(funcString: input) {
            let inputFunc = parseInfix(e: prepareForFunc(string: input))
            graphView.rpnString = inputFunc
        } else {
            showAlert(message: "Incorrect symbols")
        }
    }
    
    func showAlert(message : String) {
        let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: "Ok", style: .default)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    func isValidFunc(funcString: String) -> Bool {
        var returnValue = true
        let funcRegEx = "[x0-9-+*() ]"
        do {
            let regex = try NSRegularExpression(pattern: funcRegEx)
            let nsString = funcString as NSString
            let results = regex.matches(in: funcString, range: NSRange(location: 0, length: nsString.length))
            if results.count != funcString.count
            {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return returnValue
    }
    
    func prepareForFunc (string : String) -> String {
        var str2 = ""
        let digits = CharacterSet.decimalDigits
        for each in string.unicodeScalars {
            if digits.contains(each) || each == "x"
            {
                str2 += String(each)
            } else {
                str2 = str2 + " " + String(each) + " "
            }
        }
        return str2
    }
    
    let opa = [
        "*": (prec: 3, rAssoc: false),
        "+": (prec: 2, rAssoc: false),
        "-": (prec: 2, rAssoc: false),
        ]
    
    func rpn(tokens: [String]) -> [String] {
        var rpn : [String] = []
        var stack : [String] = []
        
        for tok in tokens {
            switch tok {
            case "(":
                stack += [tok]
            case ")":
                while !stack.isEmpty {
                    let op = stack.removeLast()
                    if op == "(" {
                        break
                    } else {
                        rpn += [op]
                    }
                }
            default:
                if let o1 = opa[tok] {
                    for op in stack.reversed() {
                        if let o2 = opa[op] {
                            if !(o1.prec > o2.prec || (o1.prec == o2.prec)) {
                                
                                rpn += [stack.removeLast()]
                                continue
                            }
                        }
                        break
                    }
                    
                    stack += [tok]
                } else {
                    rpn += [tok]
                }
            }
        }
        
        return rpn + stack.reversed()
    }
    
    func parseInfix(e: String) -> String {
        let tokens = e.split{ $0 == " " }.map(String.init)
        return rpn(tokens: tokens).joined(separator: " ")
    }
}

