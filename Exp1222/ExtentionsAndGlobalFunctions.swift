//
//  ExtentionsAndGlobalFunctions.swift
//  Exp1222
//
//  Created by Виталий Мельник on 16.12.2022.
//

import Foundation



extension String {
    //удаляет пробелы в строке
    func removeWhitespacesAll() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    //удаляет дефисы в строке
    func removeDefisAll() -> String {
        return components(separatedBy: "-").joined()
    }
    
    //удаляет все открывающие скобки в строке
    func removeParenthesisOpenAll() -> String {
        return components(separatedBy: "(").joined()
    }
    
    //удаляет все закрывающие скобки в строке
    func removeParenthesisCloseAll() -> String {
        return components(separatedBy: ")").joined()
    }
    
    //удаляет пробелы в конце строки
    func removeWhitespacesEnd() -> String {
        var n = self
        while n.last == " "{
            n.removeLast()
        }
        return n
    }
}




// concatenate attributed strings
func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
{
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
