//
//  MainTableViewCell.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UIButton!
    @IBOutlet weak var partern: UIButton!
    @IBOutlet weak var isOpen: UIButton!
    @IBOutlet weak var parternLB: UILabel!
    @IBOutlet weak var p1Btn: UIButton!
    @IBOutlet weak var p2Btn: UIButton!
    @IBOutlet weak var p3Btn: UIButton!
    @IBOutlet weak var p4Btn: UIButton!
    @IBOutlet weak var p5Btn: UIButton!
    @IBOutlet weak var p6Btn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = defaultBackgroundGrayColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.p1Btn.showsTouchWhenHighlighted = true
//        self.p1Btn.backgroundColor = UIColor.lightGrayColor()
        // Configure the view for the selected state
    }

}
