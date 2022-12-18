//
//  CustomUITextField.swift
//  Exp1222
//
//  Created by Виталий Мельник on 12.12.2022.
//

import Foundation
import UIKit

class CustomUITextField: UITextField {
    //определяет то что невозможно применить в поле ввода, к примеру копирование
   override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
   }
    
    //устанавливает курсор сразу после первого фрагмента с шрифтом одного цвета
    override func closestPosition(to point: CGPoint) -> UITextPosition? {
        var offInd = (self.text?.count)!
        if let index = getPositionDiferentFonts(){
            offInd = index
        }
            let beginning = self.beginningOfDocument
            let end = self.position(from: beginning, offset: offInd)
        
        self.selectedTextRange = self.textRange(from: end!, to: end!)
            return end
    }
    
    //функция определяющая границу шрифтов с разным цветом в пределах одного поля ввода
    func getPositionDiferentFonts() -> Int? {
        let combiText = self.attributedText
        guard let combiText = combiText else { return nil}
        guard combiText.length > 0 else { return nil}
        
        for n in 0...(combiText.length - 1){
            
            if n != 0{
                let x2 = combiText.attributes(at: n, effectiveRange: nil)
                let x1 = combiText.attributes(at: n - 1, effectiveRange: nil)
                var x2Color : UIColor? = nil
                var x1Color : UIColor? = nil
                
                for i in x1{
                    if i.key == .foregroundColor{ x1Color = i.value as? UIColor }
                }
                for i in x2{
                    if i.key == .foregroundColor { x2Color = i.value as? UIColor }
                }
                if x1Color != x2Color { return n }
            }
        }
        return nil
    }
}
