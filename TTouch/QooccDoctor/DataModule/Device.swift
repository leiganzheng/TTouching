//
//  Person.swift
//  SaupFMDB
//
//  Created by lei on 15/9/1.
//  Copyright (c) 2015年 pshao. All rights reserved.
//

import UIKit

class Device: NSObject {
    //定义属性
    var address:String?
    var dev_type:Int?
    var work_status:Int?
    var work_status1:Int?
    var work_status2:Int?
    var dev_name:String?
    var dev_status:Int?
    var dev_area:String?
    var belong_area:String?
    var is_favourited:Int?
    var icon_url:NSData?

    
    init(address:String?,dev_type:Int?,work_status:Int?,work_status1:Int?,work_status2:Int?,dev_name:String?,dev_status:Int?,dev_area:String?,
        belong_area:String?,
        is_favourited:Int?,
        icon_url:NSData?){
        
        self.address = address
        self.dev_type = dev_type
        self.work_status = work_status
        self.work_status1 = work_status1
        self.work_status2 = work_status2
        self.dev_name = dev_name
        self.dev_status = dev_status
        self.dev_area = dev_area
        self.belong_area = belong_area
        self.is_favourited = is_favourited
        self.icon_url = icon_url
    }
}
