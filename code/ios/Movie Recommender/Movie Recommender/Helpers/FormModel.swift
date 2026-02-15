//
//  MiomniFormModel.swift
//  SportsBook
//
//  Created by Georgios Smeros on 20/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func hasUppercaseLetters() -> Bool {
        for c in self {
            if c.isUppercase {return true}
        }
        return false
    }
    
}
enum FormItemCellType {
    case textField
    case attributedText
    case icon
    case image
    
    static func registerCells(for tableView: UITableView) {
        tableView.register(UINib(nibName: "FormTextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: "FormTextFieldTableViewCell")
        tableView.register(UINib(nibName: "FormAttributedTextTableViewCell", bundle: nil), forCellReuseIdentifier: "FormAttributedTextTableViewCell")
        tableView.register(UINib(nibName: "FormIconTableViewCell", bundle: nil), forCellReuseIdentifier: "FormIconTableViewCell")
        tableView.register(UINib(nibName: "FormImageTableViewCell", bundle: nil), forCellReuseIdentifier: "FormImageTableViewCell")
    }
    
    func dequeueCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        switch self {
        case .textField:
            cell = tableView.dequeueReusableCell(withIdentifier: "FormTextFieldTableViewCell", for: indexPath)
        case .attributedText:
            cell = tableView.dequeueReusableCell(withIdentifier: "FormAttributedTextTableViewCell", for: indexPath)
        case .icon:
            cell = tableView.dequeueReusableCell(withIdentifier: "FormIconTableViewCell", for: indexPath)
        case .image:
            cell = tableView.dequeueReusableCell(withIdentifier: "FormImageTableViewCell", for: indexPath)
        }
        return cell
    }
}

struct FormItemUIProperties {
    var tintColor = UIColor.black
    var keyboardType = UIKeyboardType.default
    var cellType: FormItemCellType?
}

class Form {
    static var accountCreationForm: Form {
        let form = Form()
        form.title = "Register"
        let username = TextFieldFormItem.init(titleText: "Email", placeholder: "email@email.com", properties: textCellProperties, validatorTypes: [ValidatorType.email, ValidatorType.requiredField("Email")], iconName: "email", apiKey: "username")
        let password = TextFieldFormItem.init(titleText: "Create Password", placeholder: "Enter Password", properties: textCellProperties,validatorTypes: [ValidatorType.password("Password"), ValidatorType.requiredField("Password")], iconName: "password", apiKey: "password", textType: .secureText)
        let confirmPassword = TextFieldFormItem.init(titleText: "Confirm password", placeholder: "Re-enter password", properties: textCellProperties,validatorTypes: [ValidatorType.password("Confirm password"), ValidatorType.requiredField("Confirm password")], iconName: "password", apiKey: "confirmPassword", textType: .secureText)
        form.formItems = [username, password, confirmPassword]
        return form
    }
    
    static var accountLogin: Form {
        let form = Form()
        form.title = "Login"
        let accountTitle = NSMutableAttributedString().bold("\n").bold("Login to Account", size: 18, alignment: .center)
        let accountItem = AttributedTextFormItem.init(attributedText: accountTitle)
        let username = TextFieldFormItem.init(titleText: "Email", placeholder: "email@email.com", properties: textCellProperties, validatorTypes: [ValidatorType.email, ValidatorType.requiredField("User Email")], iconName: "email", apiKey: "username")
        let password = TextFieldFormItem.init(titleText: "Password", placeholder: "Enter Password", properties: textCellProperties,validatorTypes: [ValidatorType.password("Password"), ValidatorType.requiredField("Password")], iconName: "password", apiKey: "password", textType: .secureText)
        form.formItems = [accountItem, username, password]
        return form
    }
    
    var formItems = [FormItem]() {
        didSet {
            self.results = formItems.compactMap({$0 as? FormSubmitable}).map({FormResult.init(key: $0.apiKey, value: nil)})
        }
    }
    var title: String?
    var continueButtonTitle: String?
    var results: [FormResult] = []
    var dictResults: [String: Any] {
        var dict: [String: Any] = [:]
        for result in results {
            dict[result.key] = result.value
        }
        return dict
    }
    class FormResult {
        var key: String
        var value: Any?
        
        init(key: String, value: Any?) {
            self.key = key
            self.value = value
        }
    }

    static let textCellProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .default, cellType: .textField)
    static let emailCellProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .emailAddress, cellType: .textField)
    static let numberCellProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .phonePad, cellType: .textField)
    static let moneyCellProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .decimalPad, cellType: .textField)
    static let attributedTextCellProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .default, cellType: .attributedText)
    static let iconProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .default, cellType: .icon)
    static let imageProperties = FormItemUIProperties.init(tintColor: .black, keyboardType: .default, cellType: .image)
    
    // MARK: Form Validation
    @discardableResult
    func isValid() -> (Bool, NSMutableAttributedString?) {
        
        var isValid = true
        var error: NSMutableAttributedString?
        for item in self.formItems.map({$0 as? FormValidable}) {
            if let item = item {
                if let validityError = item.checkValidity(types: item.validatorTypes) {
                    if error == nil {
                        error = validityError
                    } else {
                        let base = NSMutableAttributedString().normal("\n")
                        base.append(validityError)
                        error?.append(base)
                    }
                }
                if !item.isValid {
                    isValid = false
                }
            }
        }
        return (isValid, error)
    }
    
    struct FormSection {
        var items: [FormItem] = []
    }
}
