//
//  addressTableViewCell.swift
//  QooccDoctor
//
//  Created by haijie on 15/11/25.
//  Copyright (c) 2015年 juxi. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
