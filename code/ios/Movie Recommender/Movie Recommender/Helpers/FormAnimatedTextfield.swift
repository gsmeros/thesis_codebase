//
//  FormAnimatedTextfield.swift
//  SportsBook
//
//  Created by Miomni on 24/07/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import Foundation
import UIKit

class FormAnimatedTextfield: UITextField {
    
    var enableMaterialPlaceHolder : Bool = true
    var placeholderAttributes = NSDictionary()
    var lblPlaceHolder = UILabel()
    var difference: CGFloat = 22.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Initialize ()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Initialize ()
    }
    func Initialize(){
        self.clipsToBounds = false
        self.addTarget(self, action: #selector(FormAnimatedTextfield.textFieldDidChange), for: .editingChanged)
        self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: true)
    }
    
    @IBInspectable var placeHolderColor: UIColor? = UIColor.lightGray {
        didSet {
            guard let placeholder = self.placeholder, let placeHolderColor = self.placeHolderColor else {return}
            self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes:[.foregroundColor: placeHolderColor])
        }
    }
    
    override public var placeholder: String? {
        willSet {
            guard let newValue = newValue else {return}
            let atts:[NSAttributedString.Key : Any]  = [.foregroundColor: UIColor.lightGray, .font: self.font ?? UIFont.systemFont(ofSize: 16)]
            self.attributedPlaceholder = NSAttributedString(string: newValue, attributes:atts)
            self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
        }

    }
    override public var attributedText:NSAttributedString?  {
        willSet {
            if let placeholder = self.placeholder, let text = self.text, text != "" {
                self.placeholderText(placeholder)
            }
        }
    }
    
    @objc func textFieldDidChange(){
        if self.enableMaterialPlaceHolder {
            if (self.text == nil) || (self.text?.count)! > 0 {
                self.lblPlaceHolder.alpha = 1
                self.attributedPlaceholder = nil
                self.lblPlaceHolder.textColor = self.placeHolderColor
                self.lblPlaceHolder.frame.origin.x = 0
                let fontSize = self.font!.pointSize;
                self.lblPlaceHolder.font = UIFont.init(name: (self.font?.fontName)!, size: fontSize-3)
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
                if (self.text == nil) || (self.text?.count)! <= 0 {
                    self.lblPlaceHolder.font = self.font ?? UIFont.systemFont(ofSize: 14)
                    self.lblPlaceHolder.frame = CGRect(x: self.lblPlaceHolder.frame.origin.x+10, y : 0, width :self.frame.size.width, height : self.frame.size.height)
                }
                else {
                    self.lblPlaceHolder.frame = CGRect(x : self.lblPlaceHolder.frame.origin.x, y : -self.difference, width : self.frame.size.width, height : self.frame.size.height)
                }
            }, completion: {(finished: Bool) -> Void in
            })
        }
    }
    func EnableMaterialPlaceHolder(enableMaterialPlaceHolder: Bool){
        self.enableMaterialPlaceHolder = enableMaterialPlaceHolder
        self.lblPlaceHolder = UILabel()
        self.lblPlaceHolder.frame = CGRect(x: 0, y : 0, width : 0, height: self.frame.size.height)
        self.lblPlaceHolder.font = UIFont.systemFont(ofSize: 10)
        self.lblPlaceHolder.alpha = 0
        self.lblPlaceHolder.clipsToBounds = true
        self.addSubview(self.lblPlaceHolder)
        self.lblPlaceHolder.attributedText = self.attributedPlaceholder
    }
    
    func placeholderText(_ placeholder: String) {
        let atts:[NSAttributedString.Key : Any]  = [.foregroundColor: UIColor.lightGray, .font: self.font ?? UIFont.systemFont(ofSize: 16)]
        self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes:atts)
        self.EnableMaterialPlaceHolder(enableMaterialPlaceHolder: self.enableMaterialPlaceHolder)
    }
    
    override public func becomeFirstResponder()->(Bool){
        let returnValue = super.becomeFirstResponder()
        return returnValue
    }
    
    override public func resignFirstResponder()->(Bool){
        let returnValue = super.resignFirstResponder()
        return returnValue
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}
