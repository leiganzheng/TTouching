//
//  SixTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class SixTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var isOpen: UIButton!
    @IBOutlet weak var p1Btn: UIButton!
    @IBOutlet weak var p2Btn: UIButton!
    @IBOutlet weak var p3Btn: UIButton!
    @IBOutlet weak var p4Btn: UIButton!
    @IBOutlet weak var p5Btn: UIButton!
    @IBOutlet weak var p6Btn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
