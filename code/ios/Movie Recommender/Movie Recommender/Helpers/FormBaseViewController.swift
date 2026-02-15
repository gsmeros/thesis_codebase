//
//  FormBaseViewController.swift
//  SportsBook
//
//  Created by Georgios Smeros on 23/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import UIKit
extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font ?? UIFont.boldSystemFont(ofSize: 12)], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

extension UIView {
    func addGradient(start: UIColor, end: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [start.cgColor, end.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = self.frame
        self.clipsToBounds = true
        self.layer.insertSublayer(gradient, at: 0)
    }
}

class FormBaseViewController: UIViewController, UITextFieldDelegate {
    enum FormType {
        case create
        case login
    }
    
    var activeField: UITextField?
    
    @IBOutlet weak var tableView: UITableView!
    let bgColor = UIColor(rgb: 0xF4F4F4)
    var form = Form()
    var formType: FormType = .create
    
    private lazy var keyboardNotifications: KeyboardNotifications! = {
        return KeyboardNotifications(notifications: [.willShow, .willHide, .didShow, .didHide], delegate: self)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardNotifications.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardNotifications.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureForm()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.prepareSubViews()
        self.tableView.reloadData()
    }
    
    func configureForm() {
        switch self.formType {
        case .create:
            self.form = Form.accountCreationForm
        case .login:
            self.form = Form.accountLogin
        }
    }
    
    private func prepareSubViews() {
        FormItemCellType.registerCells(for: self.tableView)
        self.tableView.allowsSelection = false
        self.tableView.bounces = false
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = .clear
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = .clear
        self.tableView.rowHeight = UITableView.automaticDimension
        self.view.backgroundColor = self.bgColor
    }
}

// MARK: - UITableViewDataSource
extension FormBaseViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.formItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.form.formItems[indexPath.row]
        switch item.uiProperties.cellType {
        case .textField: return 80
        case .attributedText:
            if let item = item as? AttributedTextFormItem {
                let textHeight = CGFloat(item.attributedText?.numberOfLines(with: UIScreen.main.bounds.width - 40) ?? 0)*CGFloat(22)
                return textHeight + CGFloat(20)
            } else {
                return 80
            }
        case .icon: return 50
        default: return 80
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.form.formItems[indexPath.row]
        let cell: UITableViewCell
        if let cellType = self.form.formItems[indexPath.row].uiProperties.cellType {
            cell = cellType.dequeueCell(for: tableView, at: indexPath)
        } else {
            cell = UITableViewCell()
        }
        
        if let formUpdatableCell = cell as? FormConformity {
            formUpdatableCell.delegate = self
        }
        
        if let formUpdatableCell = cell as? FormUpdatable {
            formUpdatableCell.update(with: item, indexPath: indexPath)
        }
        
        return cell
    }
}

extension FormBaseViewController: FormUpdater {
    func indexDoneEditing(_ indexPath: IndexPath?) {
        guard let indexPath = indexPath else {return}
        if self.form.formItems.indices.contains(indexPath.row + 1) {
            let nextIndex = IndexPath.init(row: indexPath.row + 1, section: indexPath.section)
            if let nextCell = self.tableView.cellForRow(at: nextIndex) as? FormTextFieldTableViewCell {
                self.activeField = nextCell.ibTextField
                nextCell.ibTextField.becomeFirstResponder()
            }
        }
    }
    
    func setActiveField(_ textfield: UITextField) {
        self.activeField = textfield
    }
    
    func updateFormValue(key: String, value: Any?) {
        form.results.first(where: {$0.key == key})?.value = value
    }
}

extension FormBaseViewController: KeyboardNotificationsDelegate {

    func keyboardWillShow(notification: NSNotification) {
        guard   let userInfo = notification.userInfo as? [String: NSObject],
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        
        if self.form.formItems.count > 4 {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = contentInsets
        }
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        
        var aRect = self.parent?.view.frame ?? self.view.frame
        aRect.size.height -= keyboardFrame.height
        
        if let activeField = self.activeField, !aRect.contains(activeField.frame.origin) {
            self.tableView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    // If you don't need this func you can remove it
    func keyboardDidShow(notification: NSNotification) { print("keyboardDidShow") }
    
    // If you don't need this func you can remove it
    func keyboardDidHide(notification: NSNotification) { print("keyboardDidHide") }
}

protocol KeyboardNotificationsDelegate: class {
    func keyboardWillShow(notification: NSNotification)
    func keyboardWillHide(notification: NSNotification)
    func keyboardDidShow(notification: NSNotification)
    func keyboardDidHide(notification: NSNotification)
}

extension KeyboardNotificationsDelegate {
    func keyboardWillShow(notification: NSNotification) {}
    func keyboardWillHide(notification: NSNotification) {}
    func keyboardDidShow(notification: NSNotification) {}
    func keyboardDidHide(notification: NSNotification) {}
}
