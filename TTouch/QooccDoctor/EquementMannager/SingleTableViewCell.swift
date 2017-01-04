//
//  SingleTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class SingleTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var partern: UIButton!
    @IBOutlet weak var isOpen: UIButton!
    @IBOutlet weak var parternLB: UILabel!
    @IBOutlet weak var cmdData: UISlider!
    @IBOutlet weak var valueLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cmdData.continuous = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
