//
//  FormAttributedTextTableViewCell.swift
//  SportsBook
//
//  Created by Georgios Smeros on 25/03/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import UIKit

class FormAttributedTextTableViewCell: UITableViewCell, FormConformity {
    
    var formItem: FormItem?
    weak var delegate: FormUpdater? = nil
    
    @IBOutlet weak var textCell: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension FormAttributedTextTableViewCell: FormUpdatable {
    func update(with formItem: FormItem, indexPath: IndexPath) {
        if let formItem = formItem as? AttributedTextFormItem {
            self.formItem = formItem
            self.formItem?.indexPath = indexPath
            textCell.attributedText = formItem.attributedText
            self.backgroundView = nil
            self.textCell.backgroundColor = formItem.backgroundColor ?? .clear
            self.backgroundColor = formItem.backgroundColor ?? .clear
        }
    }
}
