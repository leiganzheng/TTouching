//
//  MCurtainTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MCurtainTableViewCell: UITableViewCell {

    @IBOutlet weak var LTitle: UILabel!
    @IBOutlet weak var L1: UIButton!
    @IBOutlet weak var L2: UIButton!
    @IBOutlet weak var L3: UIButton!
    @IBOutlet weak var RTitle: UILabel!
    @IBOutlet weak var R1: UIButton!
    @IBOutlet weak var R2: UIButton!
    @IBOutlet weak var R3: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
