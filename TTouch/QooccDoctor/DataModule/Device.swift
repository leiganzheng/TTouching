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
    var name:String?
    var height:Double?
    var pid:NSNumber?
    
    init(pid:NSNumber?,name:String?,height:Double?){
        self.pid = pid
        self.name = name
        self.height = height
    }
}
