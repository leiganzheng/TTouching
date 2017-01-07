//
//  MDoubleTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MDoubleTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UIButton!
    @IBOutlet weak var slider1: UISlider!
    @IBOutlet weak var slider2: UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.slider1.continuous = false
        self.slider2.continuous = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
