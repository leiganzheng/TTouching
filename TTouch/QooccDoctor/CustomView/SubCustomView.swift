//
//  SubCustomView.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class SubCustomView: UIView {

    var count:Int?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.updateLayerFrames()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func updateLayerFrames() {
        let lb = UILabel(frame: CGRectMake(0,0,100,20))
        lb.text = "随时"
        self.addSubview(lb)
    }

}