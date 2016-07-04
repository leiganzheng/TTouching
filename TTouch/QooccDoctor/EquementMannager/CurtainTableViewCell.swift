//
//  CurtainTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class CurtainTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var partern: UIButton!
    @IBOutlet weak var isOpen: UIButton!
    @IBOutlet weak var paternLB: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        QNTool.configViewLayerFrame(self.paternLB)
        // Configure the view for the selected state
    }

}
