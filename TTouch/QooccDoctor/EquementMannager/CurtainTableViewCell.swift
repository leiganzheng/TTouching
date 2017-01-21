//
//  CurtainTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class CurtainTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var partern: UIButton!
    @IBOutlet weak var isOpen: UIButton!
    @IBOutlet weak var paternLB: UILabel!
    @IBOutlet weak var open1Btn: UIButton!
    @IBOutlet weak var stop1Btn: UIButton!
    @IBOutlet weak var close1Btn: UIButton!
    @IBOutlet weak var open2Btn: UIButton!
    @IBOutlet weak var stop2Btn: UIButton!
    @IBOutlet weak var close2Btn: UIButton!
    @IBOutlet weak var r1: UIButton!
    @IBOutlet weak var r2: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
