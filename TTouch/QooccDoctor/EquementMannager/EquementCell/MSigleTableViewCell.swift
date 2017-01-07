//
//  MSigleTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MSigleTableViewCell: UITableViewCell {

    @IBOutlet weak var titel: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.slider.continuous = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
