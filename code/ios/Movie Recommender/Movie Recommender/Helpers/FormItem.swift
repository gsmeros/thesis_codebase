//
//  FormItem.swift
//  SportsBook
//
//  Created by Georgios Smeros on 26/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import Foundation
import UIKit

protocol FormValidable {
    var validatorTypes: [ValidatorType] {get set}
    var isValid: Bool {get set}
    func checkValidity(types: [ValidatorType]) -> NSMutableAttributedString?
}

protocol FormItem {
    var indexPath: IndexPath? {get set}
    var titleText: String {get set}
    var uiProperties: FormItemUIProperties {get set}
}

protocol FormSubmitable {
    var apiKey: String {get set}
}

class TextFieldFormItem: FormItem, FormValidable, FormSubmitable {
    
    var validatorTypes: [ValidatorType] = []
    var indexPath: IndexPath?
    var value: String?
    var placeholder = ""
    var titleText: String
    var isValid = true
    var blocked = false
    var uiProperties = FormItemUIProperties()
    var apiKey: String
    var iconName: String?
    var textType: FormTextFieldTableViewCell.FormTextType = .normalText
    var extraInfo: String?
    
    init(titleText: String , placeholder: String? = nil, value: String? = nil, properties: FormItemUIProperties,validatorTypes: [ValidatorType] = [], isUserInteractionEnabled: Bool = true, iconName: String? = nil, apiKey: String, textType: FormTextFieldTableViewCell.FormTextType = .normalText, extraInfo: String? = nil) {
        self.uiProperties = properties
        self.placeholder = placeholder ?? titleText
        self.value = value
        self.titleText = titleText
        self.blocked = !isUserInteractionEnabled
        self.apiKey = apiKey
        self.iconName = iconName
        self.textType = textType
        self.validatorTypes = validatorTypes
        self.extraInfo = extraInfo
    }
    
    func validatedText(validationType: ValidatorType) throws -> NSMutableAttributedString {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.value ?? "")
    }
    
    func validate(type: ValidatorType) -> (success: Bool, error: NSMutableAttributedString?) {
        do {
            let _ = try self.validatedText(validationType: type)
            return (success: true, error: nil)
        } catch(let error) {
            let errorMessage = (error as! ValidationError).message
            return (success: false, error: errorMessage)
        }
    }
    
    func checkValidity(types: [ValidatorType]) -> NSMutableAttributedString? {
        for type in types {
            let result = self.validate(type: type)
            if !result.success {
                self.isValid = false
                guard let message = result.error else {return NSMutableAttributedString(string: "Error")}
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                paragraph.alignment = .center
                message.addAttributes([NSAttributedString.Key.paragraphStyle: paragraph], range: NSRange.init(location: 0, length: message.length))
                return message
            }
        }
        self.isValid = true
        return nil
    }
}

class IconFormItem: FormItem {
    var value: String?
    var indexPath: IndexPath?
    var titleText: String
    var uiProperties = FormItemUIProperties()
    var tintColor: UIColor?
    var image: UIImage

    init(_ image: UIImage, tintColor: UIColor? = nil) {
        self.tintColor = tintColor
        self.uiProperties = Form.iconProperties
        self.titleText = "Icon"
        self.image = image
    }
}

class ImageFormItem: FormItem {
    var value: String?
    var indexPath: IndexPath?
    var titleText: String
    var uiProperties = FormItemUIProperties()
    var tintColor: UIColor?
    var image: UIImage

    init(_ image: UIImage, tintColor: UIColor? = nil) {
        self.tintColor = tintColor
        self.uiProperties = Form.imageProperties
        self.titleText = "Icon"
        self.image = image
    }
}

class AttributedTextFormItem: FormItem {
    var value: String?
    var indexPath: IndexPath?
    var titleText: String
    var attributedText: NSAttributedString?
    var uiProperties = FormItemUIProperties()
    var backgroundColor: UIColor?
    init(attributedText: NSAttributedString, backgroundColor: UIColor? = nil) {
        self.uiProperties = Form.attributedTextCellProperties
        self.backgroundColor = backgroundColor
        self.attributedText = attributedText
        self.titleText = "Info"
    }
}
