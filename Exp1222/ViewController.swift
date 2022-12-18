//
//  ViewController.swift
//  Exp1222
//
//  Created by Виталий Мельник on 04.12.2022.
//

import UIKit
//import CoreTelephony


class ViewController: UIViewController{

    //основные компоненты созданные в Interface Builder
    @IBOutlet weak var numberFieldOL: CustomUITextField!
    @IBOutlet weak var buttonFlagOL: UIButton!
    
    //вспомогательные элементы интерфейса
    @IBOutlet weak var phoneCodeOL: UILabel!
    @IBOutlet weak var isoCodeOL: UILabel!
    @IBOutlet weak var countryNameInEngOL: UILabel!
    @IBOutlet weak var countryNameInSysOL: UILabel!

    
    //элементы таблицы выбора страны
    private var countriesTableView: UITableView!
    var closeButton = UIButton()
    var containerView : UIView?
    
    //флаг означающий поиск по таблице через SearchBar
    var isSearch : Bool = false
    
    
    //структура необходимая для создания массива стран и организации таблицы выбора телефонного кода
    struct FlagCodeCountry {
        let flag : NSAttributedString //флаг и телефонный код
        let name : NSAttributedString //название страны на системном языке
    }
    
    var allFlagCodeCountries : [FlagCodeCountry] = [] //массив для таблицы стран
    var filteredTableData:[FlagCodeCountry] = [] //массив для поиска стран
    
    //пользовательские цвета
    let countryNameColor =          UIColor(displayP3Red: 0.333, green: 0.713, blue: 1, alpha: 1)
    let selectedCellColor =         UIColor(displayP3Red: 0, green: 0.032, blue: 0.243, alpha: 0.9)
    let backgroundCellColor =       UIColor(displayP3Red: 0, green: 0.045, blue: 0.372, alpha: 0.7)
    let searchTextFieldColor =      UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.8)
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Начальная настройка
        phoneCodeOL.text = ""
        isoCodeOL.text = ""
        countryNameInEngOL.text = ""
        countryNameInSysOL.text = ""
    }


    
    
    
    

    
    //если значение в поле ввода изменено
    @IBAction func changeValue(_ sender: UITextField) {
        newValueProcessing()
    }
    
    
    
    
    
    
    
    //если значение в поле ввода изменено
    func newValueProcessing(){
            
        let text = numberFieldOL.attributedText?.string
        guard let text = text else {return} //есть ли вообще какой либо текст в поле
            
        //определить положение курсора
        var cursorPosition = 0
        if let selectedRange = numberFieldOL.selectedTextRange {
            cursorPosition = numberFieldOL.offset(from: numberFieldOL.beginningOfDocument, to: selectedRange.start)
        }
        
        //получить текст от начала и до курсора
        let cursorPositionIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        let inputValue = String(text[..<cursorPositionIndex])
            
        //передать введённый текст в функцию определения страны, и составления шаблона номера
        processing(textIn: inputValue)
    }
    
    
    
    //анимирует кнопку которая была нажата
    func animateButtonWhenPressed(_ sender: UIButton){
        let bounds = sender.bounds
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            sender.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height + 30)
        }){(success:Bool) in
            if success{
                sender.bounds = bounds
            }
        }
    }

    //создать массив стран для отображения в таблице
    func createCountryArray(){
        allFlagCodeCountries.removeAll()
        for n in сountryIdToPhoneCode{ //перебрать все страны из масива
            //получить флаг в виде имоджи на основании кода страны
            let countryFlagEmoji = getFlag(country : n.countryCode)
            
            //указать параметры тени для флага
            let myShadow = NSShadow()
            myShadow.shadowBlurRadius = 5
            myShadow.shadowOffset = .zero
            myShadow.shadowColor = UIColor.white
            
            //создать текст с имоджи флага
            var flagText = NSMutableAttributedString(string: countryFlagEmoji, attributes:
                                                        [.font: UIFont(name: "AppleColorEmoji", size: 20)!, NSAttributedString.Key.shadow : myShadow])

            //создать текст с телефонным кодом для страны
            let phoneCodeText = NSMutableAttributedString(string: "   +\(String(n.phoneCode))", attributes:
                        [.font:UIFont.boldSystemFont(ofSize: 20),
                    .foregroundColor: UIColor.white])
            flagText = flagText + phoneCodeText as! NSMutableAttributedString //объеденить флаг и телефонный код в одну строку
           
           
            
            //получить имя страны на языке системы
            var nameCountry = ""
            //nameCountry = Locale(identifier: Locale.preferredLanguages.first!).localizedString(forRegionCode: n.countryCode) ?? ""
            nameCountry = Locale(identifier: "en-US").localizedString(forRegionCode: n.countryCode) ?? ""
            //указать параметры тени для имени страны
            let myShadow2 = NSShadow()
            myShadow2.shadowBlurRadius = 2
            myShadow2.shadowOffset = .zero
            myShadow2.shadowColor = UIColor.black
            
            //создать текст для имени страны
            let nameCountryText = NSMutableAttributedString(string: nameCountry, attributes:
                [.font:UIFont.boldSystemFont(ofSize: 18),
                 .foregroundColor: countryNameColor, NSAttributedString.Key.shadow : myShadow2])
            
            //создать новую еденицу описания страны и добавить в массив
            allFlagCodeCountries.append(FlagCodeCountry(flag: flagText, name: nameCountryText))
        }
    }
    
    //создать кнопку скрытия таблицы
    func createCloseButton(){
        let closeButtonHeightWidth : CGFloat = 40 //ширина и высота кнопки
        let shiftOverTable : CGFloat = 20 //выступ кнопки за пределы таблицы
        
        let buttonY = countriesTableView.frame.origin.y - shiftOverTable
        let buttonX = countriesTableView.frame.origin.x + countriesTableView.frame.width - closeButtonHeightWidth + shiftOverTable
        closeButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: closeButtonHeightWidth, height: closeButtonHeightWidth))
        closeButton.setBackgroundImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        closeButton.tintColor = .red
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOffset = .zero
        closeButton.layer.shadowRadius = 5
        closeButton.layer.shadowOpacity = 1
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        self.view.addSubview(closeButton)
    }
    
    //создаём вид под таблицу, для отображения тени
    func createShadowView(){
        containerView = UIView(frame:self.countriesTableView.frame)
        containerView!.backgroundColor = UIColor.black
        containerView!.layer.shadowColor = UIColor.black.cgColor
        containerView!.layer.shadowOffset = .zero
        containerView!.layer.cornerRadius = 10
        //containerView.layer.shadowOffset = CGSizeMake(10, 10); //Right-Bottom shadow
        containerView!.layer.shadowOpacity = 1.0
        containerView!.layer.shadowRadius = 5
    }
    
    //анимируем появление таблицы, вида под таблицей (с тенью) и кнопки  закрытия
    func animateTableApearenceWithCocomponents(){
        closeButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let boundsTable = countriesTableView.frame
        
        countriesTableView.frame = CGRect(x: boundsTable.origin.x, y: boundsTable.origin.y, width: 5, height: 5)
        containerView!.frame = CGRect(x: boundsTable.origin.x, y: boundsTable.origin.y, width: 5, height: 5)
        
        UIView.animate(withDuration: 0.7, animations: {
            self.countriesTableView.frame = CGRect(x: boundsTable.origin.x, y: boundsTable.origin.y, width: boundsTable.size.width, height: boundsTable.size.height)
            self.containerView!.frame = CGRect(x: boundsTable.origin.x, y: boundsTable.origin.y, width: boundsTable.size.width, height: boundsTable.size.height)
        }){_ in
            UIView.animate(withDuration: 0.7, animations: {
                self.closeButton.transform = .identity
            })
        }
    }
    
    //добавить фото для фона таблицы
    func createImageAsBackground(){
        let backgroundImage = UIImageView(frame: containerView!.bounds)
        backgroundImage.autoresizingMask = [.flexibleHeight, .flexibleWidth] // In case if your my_view_2 frames increases
        backgroundImage.image = UIImage(named: "mobile-phone-tower")
        backgroundImage.layer.masksToBounds = true
        backgroundImage.layer.cornerRadius = 10
        containerView!.insertSubview(backgroundImage, at: 0)
    }
    
    //нажатие кнопки выбора страны
    @IBAction func buttonFlagPressed(_ sender: UIButton) {
        //если таблица уже отображена - не отображать её вновь
        if containerView != nil {
            return
        }
        
        animateButtonWhenPressed(sender) //анимирует кнопку которая была нажата
        createCountryArray() //создать массив стран для отображения в таблице
        
        //создаём таблицу с размерами по ширине от левого нижнего края кнопки до правого нижнего края текстового поля ввода номера и высотой в 300 пикселей
        //вычисляем координаты левого нижнего края кнопки
        let buttonDownLeftX = buttonFlagOL.frame.origin.x
        let buttonDownLeftY = buttonFlagOL.frame.origin.y + buttonFlagOL.frame.height
        //вычисляем координаты правого нижнего края текстового поля
        let viewWidth = numberFieldOL.frame.origin.x + numberFieldOL.frame.width - buttonFlagOL.frame.origin.x
        
        countriesTableView = UITableView(frame: CGRect(x: buttonDownLeftX, y: buttonDownLeftY, width: viewWidth, height: 300), style: .grouped)
        countriesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        self.view.addSubview(countriesTableView)
        countriesTableView.backgroundColor = .clear //сделать прозрачным фон таблицы для того что бы установить в качестве фона изображение
        
        
        //for table view border
        //установить обводку таблицы
        countriesTableView.layer.borderColor = UIColor.gray.cgColor
        countriesTableView.layer.borderWidth = 1.0

        
        //for shadow
        createShadowView() //создаём вид под таблицу, для отображения тени

        //сглаживаем углы таблицы
        //for rounded corners
        countriesTableView.layer.cornerRadius = 10
        countriesTableView.layer.masksToBounds = true
        containerView!.layer.masksToBounds = false
        self.view.addSubview(containerView!)
        
        
        createImageAsBackground() //добавить фото для фона таблицы
        //таблицу выводим на передний план
        self.view.bringSubviewToFront(countriesTableView)
        
        createCloseButton() //создать кнопку скрытия таблицы
        createSearch() //создать поисковую строку
        animateTableApearenceWithCocomponents() //анимируем появление таблицы, вида под таблицей (с тенью) и кнопки  закрытия
        
        
        countriesTableView.dataSource = self
        countriesTableView.delegate = self
        animateTableApear() //анимирует появление строк таблицы
    }
    
    //выполняется при нажатии кнопки закрытия таблицы
    @objc func closeButtonPressed() {
        
        //анимируем исчезновение таблицы, вида под таблицей (с тенью) и кнопки  закрытия
        let boundsTable = countriesTableView.frame
        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }){_ in
            UIView.animate(withDuration: 0.7, animations: {
                
                
                self.countriesTableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.countriesTableView!.frame.origin = CGPoint(x: boundsTable.origin.x, y: boundsTable.origin.y)
                
                self.containerView!.frame = CGRect(x: boundsTable.origin.x, y: boundsTable.origin.y, width: 0, height: 0)
            }){_ in
                self.containerView!.removeFromSuperview()
                self.countriesTableView.removeFromSuperview()
                self.closeButton.removeFromSuperview()
                
                self.containerView = nil //необходимо для указания отсутствия отображения таблицы
            }
        }
        animateTableDisapear() //анимировать исчезновение таблицы
    }
    


    
    
    
    
    
    
    
    //Функция обрабатывающая основные ошибки
    func errorFunc(code : String? = nil){
        var errText = "error"
        if let code = code {
            errText = errText + " code \(code)"
        }
        phoneCodeOL.text = errText
        isoCodeOL.text = "error"
        countryNameInEngOL.text = "error"
        countryNameInSysOL.text = "error"
    }
    
    
    
    
    
    
    
    //функция возвращающая флаг в виде имоджи для страны код стандарта ISO 3366-1 Alpha-2 которой передан в функцию
    func getFlag(country:String) -> String {
        let base : UInt32 = 127397
        var flag = ""
        for value in country.unicodeScalars {
            flag.unicodeScalars.append(UnicodeScalar(base + value.value)!)
        }
        return String(flag)
    }
    
    //убрать все символы кроме цифр из текста
    func onlyNums(from text : String?) -> String?{
        //если никакого номера не передано
        guard var text = text else {
            errorFunc(code: "no text")
            return nil
        }
        
        //перед обработкой - удалить +, если он есть
        if text.first  == "+"{
            text.removeFirst()
        }
        
        //удалить все пробелы, дефисы и скобки
        text = text.removeWhitespacesAll().removeDefisAll().removeParenthesisOpenAll().removeParenthesisCloseAll()
        
        
        //проверить на недопустимые символы
        let allowNumeric = "1234567890"
        for character in text{
            if !allowNumeric.contains(character){
                errorFunc(code: " not allow symbols")
                //если есть что то после курсора, удалить
                markupTextAndDeleteEnd(text: text, textField: numberFieldOL)
                return nil
            }
        }
        
        //если номер ещё не введён
        if text.isEmpty {
            errorFunc(code: " продолжайте вводить номер")
            //если есть что то после курсора, удалить
            markupTextAndDeleteEnd(text: text, textField: numberFieldOL)
            return nil
        }
        return text
    }
    
    
    
    //Функция которая находит возможные варианты стран для переданного фрагмента номера
    func processing(textIn : String?){
        guard let onlyNumbersTextReserve = onlyNums(from: textIn) else { return } //сохранить копию текста подготовленную для обработки
        var text = onlyNumbersTextReserve
        
        var exitFlag = true //флаг для выхода из цикла подбора вариантов страны при номере, превышающем по колличеству символов длинну телефонного кода
        var variants: [CountryIdToPhoneCode] = [] //массив стран код которых совпадает с начаом номера
        
        //искать страны с подходящим кодом, удаляя с конца символы номера, до тех пор, пока не появится хоть один вариант
        while exitFlag {
            variants = search(text: text) //поиск всех возможных вариантов стран для этого фрагмента номера
            if variants.isEmpty { //если вариантов нет, то удалить последний символ
                text.removeLast()
                if text.isEmpty {
                    exitFlag = false //выход из цикла, так как не найдено вариантов
                }
            } else {
                exitFlag = false //выход из цикла, так как найден хоть один или более вариант
            }
        }
        
        //получив массив стран, чей телефонный код совпадает с началом номера, необходимо удалить список стран, чьи кода не совместимы с этим номером по последующим цифрам
        text = onlyNumbersTextReserve
        var newVariants : [CountryIdToPhoneCode] = []
        for variant in variants {
            var phoneCode = variant.phoneCode
            text = onlyNumbersTextReserve
            var flag = true
            
            while flag {
                if text.isEmpty || phoneCode.isEmpty {
                    newVariants.append(variant)
                    flag = false
                } else {
                    if text.first == phoneCode.first{
                        text.removeFirst()
                        phoneCode.removeFirst()
                    } else {
                        flag = false
                    }
                }
            }
        }
        
        variants = newVariants
        
        //массив variants теперь содержит все страны, код которых может совпадать с номером, введение которого начато в поле
        if variants.isEmpty {
            //если нет совпадающих стран
            phoneCodeOL.text = "error"
            isoCodeOL.text = "error"
            countryNameInEngOL.text = "error"
            countryNameInSysOL.text = "error"
            
            //если есть что то после курсора, удалить
            markupTextAndDeleteEnd(text: textIn, textField: numberFieldOL)
        } else {
            //если есть одна или более стран соответствующих введённому номеру, отобразить хотя бы одну из них
            let mainCountry = variants.first!.countryCode
            phoneCodeOL.text = variants.first!.phoneCode
            isoCodeOL.text = mainCountry
            countryNameInEngOL.text = Locale(identifier: "en-US").localizedString(forRegionCode: mainCountry)
            countryNameInSysOL.text = Locale(identifier: Locale.preferredLanguages.first!).localizedString(forRegionCode: mainCountry)
            
            //в случае единственного варианта страны, создать шаблон номера
            var fullExample : String? = nil
            if variants.count == 1{
                for n in сountryIdToPhoneCode{
                    if n.countryCode == mainCountry{
                        fullExample = n.example
                        break
                    }
                }
                
                if let fullExample = fullExample{
                    var endExample = "" //будет содержать только ту часть примера записи номера для страны, которая ещё отсутствует в поле ввода
                    var startFormatted = "" //будет содержать уже введённую часть номера, переписанную в соответствии с шаблоном номера
                    var textMod = onlyNumbersTextReserve //необходимо для составления startFormatted
                    
                    //составляем startFormatted и endExample
                    for character in fullExample{
                        if !textMod.isEmpty{
                            switch character {
                            case "0","1","2","3","4","5","6","7","8","9" :
                                startFormatted.append(textMod.first!)
                                textMod.removeFirst()
                            default :
                                startFormatted.append(character)
                            }
                        } else {
                            endExample.append(character)
                        }
                    }
                    
                    //получить флаг в виде имоджи на основании кода страны и установка этого флага как текст кнопки
                    let countryFlagEmoji = getFlag(country : mainCountry)
                    let countryFlagEmojiText = NSMutableAttributedString(string: countryFlagEmoji, attributes:
                                                                [.font: UIFont(name: "AppleColorEmoji", size: 40)!])
                    buttonFlagOL.setAttributedTitle(countryFlagEmojiText, for: .normal)
                    
                    //составить текст для отображения в поле ввода как форматированный текст из двух частей - уже введёного номера и шаблона ещё не введённой части  номера
                    let attributedText = NSMutableAttributedString(string: startFormatted, attributes:
                        [.font:UIFont.boldSystemFont(ofSize: 20),
                    .foregroundColor: UIColor.darkGray])

                    attributedText.append(NSAttributedString(string: endExample, attributes:
                        [.font: UIFont.italicSystemFont(ofSize: 20),
                         .foregroundColor: UIColor.lightGray]))
                    
                    numberFieldOL.attributedText = attributedText //отобразить в поле ввода подготовленный номер и шаблон
                    
                    //установить курсор в конце введённой пользователем части номера
                    let arbitraryValue: Int = startFormatted.count
                    if let newPosition = numberFieldOL.position(from: numberFieldOL.beginningOfDocument, offset: arbitraryValue) {
                        numberFieldOL.selectedTextRange = numberFieldOL.textRange(from: newPosition, to: newPosition)
                    }
                }
            } else {
                //если есть что то после курсора, удалить
                markupTextAndDeleteEnd(text: textIn, textField: numberFieldOL)
            }
        }
    }
    
    
    //поиск всех возможных вариантов стран для этого фрагмента номера
    func search(text: String) -> [CountryIdToPhoneCode]{
        var result : [CountryIdToPhoneCode] = []
        
        for country in сountryIdToPhoneCode{
            var textCopy = text
            var phoneCode = country.phoneCode
            var flag = 1
            
            while flag == 1 {
                if phoneCode.count > 0{
                    if textCopy.count > 0{
                        if phoneCode.first == textCopy.first{
                            phoneCode.removeFirst()
                            textCopy.removeFirst()
                        } else {
                            flag = 0
                        }
                    } else {
                        result.append(country)
                        flag = 0
                    }
                } else {
                    if textCopy.count > 0{
                        flag = 0
                    } else {
                        result.append(country)
                        flag = 0
                    }
                }
            }
        }
        return result
    }
    
    
    
    
    
    
    //если есть что то после курсора, удалить, а то что до курсора привести к виду маркированого как введённый пользователем чать номера
    func markupTextAndDeleteEnd(text : String?, textField : UITextField){
        let attributedText = NSMutableAttributedString(string: text ?? "", attributes:
            [.font:UIFont.boldSystemFont(ofSize: 20),
             .foregroundColor: UIColor.darkGray])
        textField.attributedText = attributedText
        
        //получить флаг в виде имоджи на основании кода страны и установка этого флага как текст кнопки
        let attrText2 = NSMutableAttributedString(string: "🏳️", attributes:
                                                    [.font: UIFont(name: "AppleColorEmoji", size: 40)!])
        buttonFlagOL.setAttributedTitle(attrText2, for: .normal)
    }
}




//ФУНКЦИИ ОБЕСПЕЧИВАЮЩИЕ ФУНКЦИОНАЛ ТАБЛИЦЫ
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    //при снятии выбора ячейки таблицы
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         let selectedCell:UITableViewCell? = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.clear
    }
    
    //при выборе ячейки таблицы
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = selectedCellColor
        //выбран пункт из таблицы
        //проверить соответствует ли код в поле ввода выбраному коду
        //если не соответствует - заменить
        
        //получить код выбранной страны в чистом виде
        var code : String = ""
        if isSearch {
            code = filteredTableData[indexPath.row].flag.string
            }
        else {
            code = allFlagCodeCountries[indexPath.row].flag.string
            }
        
        
        let nums = "0123456789"
        var normCode = "+"
        for n in code {
            if nums.contains(n){
                normCode.append(n)
            }
        }
        
        //сравнить первые символы в текстовом поле на совпадение с кодом выбраной страны
        var equal = true
        if let fieldTxt = numberFieldOL.text{
            if fieldTxt.count >= normCode.count{
                
                for (i,n) in normCode.enumerated(){
                    let index = fieldTxt.index(fieldTxt.startIndex, offsetBy: i)
                    if fieldTxt[index] != n{
                        equal = false
                    }
                }
            } else {
                equal = false
            }
        } else {
            equal = false
        }
        
        //если код выбранной страны не совпадает с введённым в поле - то удалить всё из текстового поля и добавить код выбраной страны
        if !equal{
            numberFieldOL.becomeFirstResponder() //отобразить клавиатуру
            numberFieldOL.text = normCode
            //установить курсор в конец поля
            let newPosition = numberFieldOL.endOfDocument
            numberFieldOL.selectedTextRange = numberFieldOL.textRange(from: newPosition, to: newPosition)
            
            newValueProcessing() //обновить флаг и шаблон номера
        }
    }

    //число ячеек в таблице
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        if isSearch {
                     return filteredTableData.count //в случае фильтрации списка стран с помощью поисковой строки
                 }else{
                     return allFlagCodeCountries.count //в случае полного списка возможных стран
                }
        }

    //установить текст, дизайн конкретной ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        //задать стиль ячейки
        cell = UITableViewCell(style: UITableViewCell.CellStyle.value1,
                        reuseIdentifier: "MyCell")
        
        //установить значения текста ячейки используя полный или фильтрованый список стран в зависимости от того осуществляется ли поиск в данный момент при помощи поисковой строки
        var temp : FlagCodeCountry? = nil
        if isSearch {
            temp = filteredTableData[indexPath.row]
        } else {
            temp = allFlagCodeCountries[indexPath.row]
        }
        
        cell.textLabel!.attributedText = temp?.flag //установить флаг и телефонный код страны
        
        cell.detailTextLabel?.numberOfLines = 0 //разрешить перенос слов в строке
        
        cell.detailTextLabel!.attributedText = temp?.name //установить имя страны
        cell.selectionStyle = .none //отменить стиль выбора строк при нажатии по умолчанию
        return cell
        }
    
    //задаёт цвет ячеек таблицы в зависимости от того выбрана ли ячейка
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !cell.isSelected{
            cell.backgroundColor = backgroundCellColor
        } else {
            cell.backgroundColor = selectedCellColor
        }
    }

    
    //анимирует появление строк таблицы (https://www.youtube.com/watch?v=FpTY04efWC0)
    func animateTableApear(){
        countriesTableView.reloadData()
        let cells = countriesTableView.visibleCells
        let tableViewHeight = countriesTableView.bounds.size.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0
        for cell in cells{
            UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform.identity
            })
            delayCounter += 1
        }
    }
    
    
    //анимирует исчезновение строк таблицы
    func animateTableDisapear(){
        let cells = countriesTableView.visibleCells
        let tableViewHeight = countriesTableView.bounds.size.height
        
        var delayCounter = 0
        for cell in cells{
            UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: -tableViewHeight)
            })
            delayCounter += 1
        }
    }

}





extension ViewController : UISearchBarDelegate{
    //функция создающия поисковую строку в таблице
    func createSearch() {
        let searchBar:UISearchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        searchBar.backgroundColor = backgroundCellColor
        searchBar.searchTextField.backgroundColor = searchTextFieldColor
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        countriesTableView.tableHeaderView = searchBar //Here change your view name
    }
    
    
    //MARK: UISearchbar delegate
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
               //isSearch = true
        }
           
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
           
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
           
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
               searchBar.resignFirstResponder()
               isSearch = false
        }
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.count == 0 {
                isSearch = false
                self.countriesTableView.reloadData()
            } else {
                filteredTableData = allFlagCodeCountries.filter({ (unit) -> Bool in
                    
                    let tmp: NSString = unit.name.string as NSString
                    let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                    return range.location != NSNotFound
                })
                if(filteredTableData.count == 0){
                    isSearch = false
                } else {
                    isSearch = true
                }
                self.countriesTableView.reloadData()
            }
        }
}
