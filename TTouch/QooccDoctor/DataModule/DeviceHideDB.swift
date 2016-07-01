//
//  DeviceHide.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/1.
//  Copyright © 2016年 juxi. All rights reserved.
//


import UIKit

class DeviceHideDB: NSObject {
    //定义属性
    var address:String?
    var isHidden:Int?
    var huiluId:Int?
    
    
    init(address:String?,isHidden:Int?,huiluId:Int?){
        
        self.address = address
        self.isHidden = isHidden
        self.huiluId = huiluId
       
    }
}