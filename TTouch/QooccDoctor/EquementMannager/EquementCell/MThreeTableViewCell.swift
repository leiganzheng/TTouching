//
//  MThreeTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MThreeTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UIButton!
    @IBOutlet weak var r1Btn: UIButton!
    @IBOutlet weak var r2Btn: UIButton!
    @IBOutlet weak var r3Btn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
