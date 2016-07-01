//
//  Pattern.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/1.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class PatternDB: NSObject {
    //定义属性
    var tip:String?
    var work_status_open:Int?
    var work_status_save:Int?
    var name:String?
    var area:String?
    
    
    init(tip:String?,work_status_open:Int?,work_status_save:Int?,name:String?,area:String?){
        
        self.tip = tip
        self.work_status_open = work_status_open
        self.work_status_save = work_status_save
        self.name = name
        self.area = area
        
    }

}
