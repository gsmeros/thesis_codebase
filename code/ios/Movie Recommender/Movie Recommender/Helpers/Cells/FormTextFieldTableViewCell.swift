//
//  FormTextFieldTableViewCell.swift
//  SportsBook
//
//  Created by Georgios Smeros on 23/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import UIKit
import Foundation

/// Conform the view receiver to be updated with a form item
protocol FormUpdatable: class {
    func update(with formItem: FormItem, indexPath: IndexPath)
}

/// Conform receiver to have a form item property
protocol FormConformity: class {
    var delegate: FormUpdater? {get set}
    var formItem: FormItem? {get set}
}

protocol FormUpdater: class {
    func updateFormValue(key: String, value: Any?)
    func indexDoneEditing(_ indexPath: IndexPath?)
    func setActiveField(_ textfield: UITextField)
}

class FormTextFieldTableViewCell: UITableViewCell, FormConformity, UITextFieldDelegate {
    
    enum FormTextType {
        case normalText
        case secureText
        case socialSecurityNumber
    }
    
    @IBOutlet weak var ibTextField: FormTextField!
    @IBOutlet weak var extraInfoLabel: UILabel!
    
    var formItem: FormItem?
    weak var delegate: FormUpdater?
    var textType: FormTextType = .normalText
    
    let normalTextColor = UIColor.black
    let textfieldLine = UIColor.mainBlueColor(opacity: 0.25)
    let alertColor = UIColor.red
    let bottomLine = CALayer()
    let backgroundCell = UIColor.clear
    let activeBackgroundCell = UIColor.mainBlueColor(opacity: 0.25)

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.ibTextField.font = CustomFont.main(.regular, size: 18)
        self.ibTextField.delegate = self
        self.ibTextField.addTarget(self, action: #selector(textFieldDidChanged(_:)), for: .editingChanged)
        self.ibTextField.inputAccessoryView = createToolBarForPicker(self.ibTextField)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.setActiveField(textField)
        (self.formItem as? TextFieldFormItem)?.isValid = true
        self.updateFieldValidity()
        bottomLine.backgroundColor = activeBackgroundCell.cgColor
        self.backgroundColor = activeBackgroundCell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        bottomLine.backgroundColor = textfieldLine.cgColor
        self.backgroundColor = backgroundCell
    }
    
    @objc func textFieldDidChanged(_ textField: UITextField) {
        self.updateForm(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.indexDoneEditing(self.formItem?.indexPath)
        return true
    }
    
    func createToolBarForPicker(_ textField: UITextField) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.ibTextField.endEditing(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.tintColor = UIColor.black
        doneButton.tintColor = UIColor.black
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                toolBar.tintColor = UIColor.white
                doneButton.tintColor = UIColor.white
                doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
            }
        }
        toolBar.sizeToFit()
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    func updateForm(_ value: String?) {
        if let item = self.formItem as? TextFieldFormItem {
            item.value = value
            self.delegate?.updateFormValue(key: item.apiKey, value: value)
        }
    }
}

// MARK: - FormUpdatable
extension FormTextFieldTableViewCell: FormUpdatable {
    func update(with formItem: FormItem, indexPath: IndexPath) {
        if let formItem = formItem as? TextFieldFormItem {
            
            bottomLine.frame = CGRect(x: 0.0, y: self.frame.height - 1, width: self.frame.width, height: 1.0)
            bottomLine.backgroundColor = textfieldLine.cgColor
            ibTextField.borderStyle = UITextField.BorderStyle.none
            self.layer.addSublayer(bottomLine)
            
            self.formItem = formItem
            self.textType = formItem.textType
            self.formItem?.indexPath = indexPath
            self.updateForm(formItem.value)
            if let imageName = formItem.iconName, let image = UIImage.init(named: imageName) {
                self.ibTextField.setIcon(image, color: normalTextColor, position: .left)
            } else {
                self.ibTextField.removeIcon(position: .left)
            }
            
            self.ibTextField.text = formItem.value
            self.ibTextField.placeholderText(formItem.placeholder)
            
            self.backgroundView = nil
            self.backgroundColor = backgroundCell
            self.ibTextField.textColor = self.normalTextColor
            self.ibTextField.keyboardType = formItem.uiProperties.keyboardType
            self.ibTextField.returnKeyType = .next
            self.extraInfoLabel.textColor = self.normalTextColor
            self.extraInfoLabel.text = formItem.extraInfo
            self.ibTextField.tintColor = self.normalTextColor
            self.ibTextField.isUserInteractionEnabled = !(formItem.blocked)
            self.ibTextField.isSecureTextEntry = formItem.textType != .normalText

            self.updateFieldValidity()
        }
    }
    
    func updateFieldValidity() {
        guard let formItem = self.formItem as? TextFieldFormItem else {return}
        let bgColor: UIColor = formItem.isValid == false ? alertColor : textfieldLine
        bottomLine.backgroundColor = bgColor.cgColor

        if !formItem.isValid {
            self.ibTextField.setIcon(UIImage.init(named: "errorAlert") ?? UIImage(), color: alertColor, position: .right)
        } else {
            self.ibTextField.removeIcon(position: .right)
        }
    }
}
