//
//  NSAttributedStringExtensions.swift
//  SportsBook
//
//  Created by George Smeros on 16/10/2019.
//  Copyright © 2019 Miomni. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, size: CGFloat = 16, color: UIColor? = nil, alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = alignment
        if let color = color {
            attrs = [.font: CustomFont.main(.bold, size: Double(size)), .foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph]
        } else {
            attrs = [.font: CustomFont.main(.bold, size: Double(size)), NSAttributedString.Key.paragraphStyle: paragraph]
        }
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func medium(_ text: String, size: CGFloat = 16, color: UIColor? = nil, alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = alignment
        if let color = color {
            attrs = [.font: CustomFont.main(.medium, size: Double(size)), .foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph]
        } else {
            attrs = [.font: CustomFont.main(.medium, size: Double(size)), NSAttributedString.Key.paragraphStyle: paragraph]
        }
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String, size: CGFloat = 16, color: UIColor? = nil, alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = alignment
        if let color = color {
            attrs = [.font: CustomFont.main(.regular, size: Double(size)), .foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph]
        } else {
            attrs = [.font: CustomFont.main(.regular, size: Double(size)), NSAttributedString.Key.paragraphStyle: paragraph]
        }
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    
    @discardableResult func light(_ text: String, size: CGFloat = 16, color: UIColor? = nil, alignment: NSTextAlignment = .left) -> NSMutableAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [:]
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = alignment
        if let color = color {
            attrs = [.font: CustomFont.main(.light, size: Double(size)), .foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph]
        } else {
            attrs = [.font: CustomFont.main(.light, size: Double(size)), NSAttributedString.Key.paragraphStyle: paragraph]
        }
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
}

struct CustomFont {

    enum LabelType {
        case title, header, subHeading, info
    }
    
    enum FontWeight {
        case light, regular, medium, bold
    }
    
    static func main(_ weight: FontWeight, size: Double) -> UIFont {
        let fontName: FontName
        switch weight {
        case .light: fontName = FontName.Light
        case .regular: fontName = FontName.Regular
        case .medium: fontName = FontName.Medium
        case .bold: fontName = FontName.Bold
        }
        let font = CustomFont(.installed(fontName),size: .custom(size))
        return font.instance
    }
    
    enum FontType {
        case installed(FontName)
        case custom(String)
    }
    
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    
    enum FontName: String {
        case Black            = "Roboto-Black"
        case BlackItalic      = "Roboto-BlackItalic"
        case Bold             = "Roboto-Bold"
        case BoldItalic       = "Roboto-BoldItalic"
        case Italic           = "Roboto-Italic"
        case Light            = "Roboto-Light"
        case LightItalic      = "Roboto-LightItalic"
        case Medium           = "Roboto-Medium"
        case MediumItalic     = "Roboto-MediumItalic"
        case Regular          = "Roboto-Regular"
        case Thin             = "Roboto-Thin"
        case ThinItalic       = "Roboto-ThinItalic"
    }
    
    enum StandardSize: Double {
        case h1 = 20.0
        case h2 = 18.0
        case h3 = 16.0
        case h4 = 14.0
        case h5 = 12.0
        case h6 = 10.0
    }

    
    var type: FontType
    var size: FontSize
    init(_ type: FontType, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension CustomFont {
    
    var instance: UIFont {
        
        var instanceFont: UIFont!
        switch type {
        case .custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                return UIFont.systemFont(ofSize: CGFloat(size.value))
            }
            instanceFont = font
        case .installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                return UIFont.systemFont(ofSize: CGFloat(size.value))
            }
            instanceFont = font
        }
        return instanceFont
    }
}

