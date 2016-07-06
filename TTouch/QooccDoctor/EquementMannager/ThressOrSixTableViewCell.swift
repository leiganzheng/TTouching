//
//  ThressOrSixTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class ThressOrSixTableViewCell: UITableViewCell {

    @IBOutlet weak var isopen: UIButton!
    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var patern: UIButton!
    @IBOutlet weak var paternLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
