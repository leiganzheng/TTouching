//
//  YaoDBModel.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/1.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit

class YaoDBModel: NSObject {
    //定义属性
    var pattern_id:Double?
    var area:String?
    
    
    init(area:String?,pattern_id:Double?){
        
        self.pattern_id = pattern_id
        self.area = area
        
    }

}
