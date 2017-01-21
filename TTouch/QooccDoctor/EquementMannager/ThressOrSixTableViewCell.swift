//
//  ThressOrSixTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/3.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class ThressOrSixTableViewCell: UITableViewCell {

    @IBOutlet weak var isopen: UIButton!
    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var patern: UIButton!
    @IBOutlet weak var paternLB: UILabel!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var switch3: UISwitch!
    @IBOutlet weak var switch4: UISwitch!
    @IBOutlet weak var switch5: UISwitch!
    @IBOutlet weak var switch6: UISwitch!
    @IBOutlet weak var r1: UIButton!
    @IBOutlet weak var r2: UIButton!
    @IBOutlet weak var r3: UIButton!
    @IBOutlet weak var r4: UIButton!
    @IBOutlet weak var r5: UIButton!
    @IBOutlet weak var r6: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
