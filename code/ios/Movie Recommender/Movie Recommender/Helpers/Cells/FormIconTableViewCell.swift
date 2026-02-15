//
//  FormIconTableViewCell.swift
//  SportsBook
//
//  Created by Georgios Smeros on 07/04/2020.
//  Copyright © 2020 Miomni. All rights reserved.
//

import UIKit

class FormIconTableViewCell: UITableViewCell, FormConformity, FormUpdatable {
    
    @IBOutlet weak var iconView: UIImageView!
    
    func update(with formItem: FormItem, indexPath: IndexPath) {
        self.iconView.image = nil
        if let formItem = formItem as? IconFormItem {
            self.formItem = formItem
            if let tint = formItem.tintColor {
                if #available(iOS 13.0, *) {
                    self.iconView.image = formItem.image.withTintColor(tint)
                } else {
                    self.iconView.image = formItem.image.withRenderingMode(.alwaysTemplate)
                    self.iconView.tintColor = formItem.tintColor
                }
            }
            self.iconView.contentMode = .scaleAspectFit
        }
    }
    
    weak var delegate: FormUpdater? = nil
    var formItem: FormItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.backgroundView = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
