//
//  SubCustomView.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SubCustomView: UIView {

    var data:NSArray?{
        get {
            return data
        }
        set(newData) {
            data = newData
            self.updateLayerFrames()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        self.updateLayerFrames()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func updateLayerFrames() {
        for index in 0 ..< data!.count {
            let button:UIButton = UIButton(frame: CGRectMake(CGFloat(index%2)*(screenWidth/2), CGFloat(index%2)*50,screenWidth/2, 50))
            button.setImage(UIImage(named: "navigation_Menu_icon"), forState: UIControlState.Normal)
            button.setTitle("", forState: UIControlState.Normal)
            button.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                return RACSignal.empty()
                })

        }
    }

}
