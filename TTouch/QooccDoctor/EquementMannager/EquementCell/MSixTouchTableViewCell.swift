//
//  MSixTouchTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/8/17.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit

class MSixTouchTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UIButton!
    @IBOutlet weak var l1: UIButton!
    @IBOutlet weak var l2: UIButton!
    @IBOutlet weak var l3: UIButton!
    @IBOutlet weak var r1: UIButton!
    @IBOutlet weak var r2: UIButton!
    @IBOutlet weak var r3: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
