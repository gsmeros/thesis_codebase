//
//  FormHelperFunctions.swift
//  SportsBook
//
//  Created by Georgios Smeros on 25/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func count(of needle: Character) -> Int {
        return reduce(0) {
            $1 == needle ? $0 + 1 : $0
        }
    }
}

extension NSAttributedString {
    
    func numberOfLines(with width: CGFloat) -> Int {
        
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT)))
        let frameSetterRef : CTFramesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let frameRef: CTFrame = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path.cgPath, nil)
        
        let linesNS: NSArray  = CTFrameGetLines(frameRef)
        
        guard let lines = linesNS as? [CTLine] else { return 0 }
        return lines.count
    }
}

class FormTextField: UITextField {
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: (leftView == nil) ? 20 : 45, bottom: 0, right: 20)
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: (leftView == nil) ? 20 : 45, bottom: 0, right: 20)
        
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsets(top: 0, left: (leftView == nil) ? 20 : 45, bottom: 0, right: 20)
        return bounds.inset(by: padding)
    }
    
    var placeholderAttributes = NSDictionary()
    var lblPlaceHolder: UILabel?
    var difference: CGFloat = 22.0
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        self.clipsToBounds = false
        self.addTarget(self, action: #selector(FormAnimatedTextfield.textFieldDidChange), for: .editingChanged)
        self.enabledAnimatedPlaceholder()
        self.lblPlaceHolder?.removeFromSuperview()
        self.lblPlaceHolder = nil
    }
    
    @IBInspectable var placeHolderColor: UIColor? = UIColor.lightGray {
        didSet {
            guard let placeholder = self.placeholder, let placeHolderColor = self.placeHolderColor else {return}
            self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes:[.foregroundColor: placeHolderColor])
        }
    }
    
    @IBInspectable var placeHolderColorOn: UIColor? = UIColor.lightGray {
        didSet {
            guard let placeholder = self.placeholder, let placeHolderColor = self.placeHolderColor else {return}
            self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes:[.foregroundColor: placeHolderColor])
        }
    }
    
    override public var placeholder: String? {
        willSet {
            guard let newValue = newValue else {return}
            let atts:[NSAttributedString.Key : Any]  = [.foregroundColor: self.placeHolderColor ?? .lightGray, .font: self.font ?? CustomFont.main(.regular, size: 18)]
            self.attributedPlaceholder = NSAttributedString(string: newValue, attributes:atts)
            self.enabledAnimatedPlaceholder()
        }
        
    }
    override public var attributedText:NSAttributedString?  {
        willSet {
            if let placeholder = self.placeholder, let text = self.text, text != "" {
                self.placeholderText(placeholder)
            }
        }
    }
    
    func updatePlaceholder(_ animated: Bool = true) {
        if (self.text == nil) || (self.text?.count)! > 0 {
            self.lblPlaceHolder?.alpha = 1
            self.attributedPlaceholder = nil
            self.lblPlaceHolder?.textColor = self.placeHolderColorOn
            self.lblPlaceHolder?.frame.origin.x = (leftView == nil) ? 20 : 45
            self.lblPlaceHolder?.font = CustomFont.main(.regular, size: 15)
        }
        
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {() -> Void in
            if (self.text == nil) || self.text?.count ?? 0 <= 0 {
                self.lblPlaceHolder?.font = self.font ?? CustomFont.main(.regular, size: 18)
                self.lblPlaceHolder?.frame = CGRect(x: self.lblPlaceHolder?.frame.origin.x ?? 0, y : 0, width :self.frame.size.width, height : self.frame.size.height)
            }
            else {
                self.lblPlaceHolder?.frame = CGRect(x : self.lblPlaceHolder?.frame.origin.x ?? 0, y : -self.difference, width : self.frame.size.width, height : self.frame.size.height)
            }
        }, completion: {(finished: Bool) -> Void in
            DispatchQueue.main.async {
                if (self.text == nil) || self.text?.count ?? 0 <= 0 {
                    self.lblPlaceHolder?.textColor = self.placeHolderColor
                } else {
                    self.lblPlaceHolder?.textColor = self.placeHolderColorOn
                }
            }
        })
    }
    
    @objc func textFieldDidChange() {
        updatePlaceholder(true)
    }
    
    func enabledAnimatedPlaceholder() {
        self.lblPlaceHolder?.removeFromSuperview()
        self.lblPlaceHolder = nil
        self.lblPlaceHolder = UILabel()
        self.lblPlaceHolder?.frame = CGRect(x: 0, y : 0, width : 0, height: self.frame.size.height)
        self.lblPlaceHolder?.font = CustomFont.main(.regular, size: 18)
        self.lblPlaceHolder?.alpha = 0
        self.lblPlaceHolder?.clipsToBounds = true
        self.lblPlaceHolder?.attributedText = self.attributedPlaceholder
        if let lblPlaceHolder = lblPlaceHolder {self.addSubview(lblPlaceHolder)}
        updatePlaceholder(false)
    }
    
    func placeholderText(_ placeholder: String) {
        let atts:[NSAttributedString.Key : Any]  = [.foregroundColor: self.placeHolderColor ?? .lightGray, .font: self.font ?? CustomFont.main(.regular, size: 18)]
        self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes:atts)
        self.enabledAnimatedPlaceholder()
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


extension FormTextField {
    
    func removeIcon(position: TextFieldImagePosition) {
        if position == .left {
            leftView = nil
        } else {
            rightView = nil
        }
    }
    
    enum TextFieldImagePosition {
        case left,right
    }
    
    func setIcon(_ image: UIImage, color: UIColor, position: TextFieldImagePosition) {
        
        let iconView = UIImageView(frame:
                                    CGRect(x: position == .left ? 20 : 0, y: 5, width: 20, height: 20))
        iconView.isUserInteractionEnabled = false
        if #available(iOS 13.0, *) {
            iconView.image = image.withTintColor(color)
        } else {
            iconView.image = image.withRenderingMode(.alwaysTemplate)
            iconView.tintColor = color
        }
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 0, y: 0, width: 40, height: 30))
        iconContainerView.addSubview(iconView)
        iconContainerView.isUserInteractionEnabled = false
        if position == .left {
            leftView = iconContainerView
            leftViewMode = .always
        } else {
            rightView = iconContainerView
            rightView?.isUserInteractionEnabled = false
            rightViewMode = .always
        }
    }
}

public struct UIImageViewAlignmentMask: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    /// The option to align the content to the center.
    public static let center = UIImageViewAlignmentMask(rawValue: 0)
    /// The option to align the content to the left.
    public static let left = UIImageViewAlignmentMask(rawValue: 1 << 0)
    /// The option to align the content to the right.
    public static let right = UIImageViewAlignmentMask(rawValue: 1 << 1)
    /// The option to align the content to the top.
    public static let top = UIImageViewAlignmentMask(rawValue: 1 << 2)
    /// The option to align the content to the bottom.
    public static let bottom = UIImageViewAlignmentMask(rawValue: 1 << 3)
    /// The option to align the content to the top left.
    public static let topLeft: UIImageViewAlignmentMask = [top, left]
    /// The option to align the content to the top right.
    public static let topRight: UIImageViewAlignmentMask = [top, right]
    /// The option to align the content to the bottom left.
    public static let bottomLeft: UIImageViewAlignmentMask = [bottom, left]
    /// The option to align the content to the bottom right.
    public static let bottomRight: UIImageViewAlignmentMask = [bottom, right]
}

class KeyboardNotifications {
    
    fileprivate var _isEnabled: Bool
    fileprivate var notifications: [KeyboardNotificationsType]
    fileprivate weak var delegate: KeyboardNotificationsDelegate?
    
    init(notifications: [KeyboardNotificationsType], delegate: KeyboardNotificationsDelegate) {
        _isEnabled = false
        self.notifications = notifications
        self.delegate = delegate
    }
    
    deinit { if isEnabled { isEnabled = false } }
}

// MARK: - enums

extension KeyboardNotifications {
    
    enum KeyboardNotificationsType {
        case willShow, willHide, didShow, didHide
        
        var selector: Selector {
            switch self {
            case .willShow: return #selector(keyboardWillShow(notification:))
            case .willHide: return #selector(keyboardWillHide(notification:))
            case .didShow: return #selector(keyboardDidShow(notification:))
            case .didHide: return #selector(keyboardDidHide(notification:))
            }
        }
        
        var notificationName: NSNotification.Name {
            switch self {
            case .willShow: return UIResponder.keyboardWillShowNotification
            case .willHide: return UIResponder.keyboardWillHideNotification
            case .didShow: return UIResponder.keyboardDidShowNotification
            case .didHide: return UIResponder.keyboardDidHideNotification
            }
        }
    }
}

// MARK: - isEnabled

extension KeyboardNotifications {
    
    private func addObserver(type: KeyboardNotificationsType) {
        NotificationCenter.default.addObserver(self, selector: type.selector, name: type.notificationName, object: nil)
    }
    
    var isEnabled: Bool {
        set {
            if newValue {
                for notificaton in notifications { addObserver(type: notificaton) }
            } else {
                NotificationCenter.default.removeObserver(self)
            }
            _isEnabled = newValue
        }
        
        get { return _isEnabled }
    }
    
}

// MARK: - Notification functions

extension KeyboardNotifications {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        delegate?.keyboardWillShow(notification: notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        delegate?.keyboardWillHide(notification: notification)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        delegate?.keyboardDidShow(notification: notification)
    }
    
    @objc func keyboardDidHide(notification: NSNotification) {
        delegate?.keyboardDidHide(notification: notification)
    }
}

class SkinTextField: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setFont()
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setFont()
    }
    
    func setFont() {
        self.font = CustomFont.main(.regular, size: 16)
    }
}

extension UIColor {
    
    static func mainBlueColor(opacity: CGFloat = 1.0) -> UIColor {
        let color = UIColor(rgb: 0x446BCF).withAlphaComponent(opacity)
        return color
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
