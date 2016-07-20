//
//  DCAlarmManager.swift
//  Demo_Clock
//
//  Created by luxiaoming on 16/1/21.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

import UIKit

class DCAlarmManager {
    var alarmArray: NSMutableArray
    
    static let sharedInstance = DCAlarmManager()
    
    
    private init() {
        if let alarmArrayData = NSUserDefaults.standardUserDefaults().objectForKey("alarmArray") as? NSData {
            let tempArray = NSKeyedUnarchiver.unarchiveObjectWithData(alarmArrayData) as! NSArray
            self.alarmArray = NSMutableArray(array: tempArray)
        } else {
            self.alarmArray = NSMutableArray()
        }
        
    }
    
    
    func save() {
        let alarmArrayData = NSKeyedArchiver.archivedDataWithRootObject(self.alarmArray)
        NSUserDefaults.standardUserDefaults().setObject(alarmArrayData, forKey: "alarmArray")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
