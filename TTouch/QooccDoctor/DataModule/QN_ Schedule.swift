//
//  QN_ Schedule.swift
//  QooccHealth
//
//  Created by leiganzheng on 15/9/1.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
/// 预约日程
class QN_Schedule: QN_Base {
    
    var addressId: String?     // 地点id
    var address: String?     // 地点
    var scheduleId: String!     // id
    var timeRange: String?    // 时间范围
    var acceptCount:String!      // 可预约人数
    var bookedCount: String?       // 已预约人数
    var remain: String!   // 剩余可预约人数
    var disabled: String?   // 0:可预约 ; 1: 不可预约
    
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, "scheduleId") {
            super.init(dictionary)
            return nil
        }
        
        // 所需要的数据都存在，则开始真正的数据初始化
        self.scheduleId = dictionary["scheduleId"] as! String
        self.timeRange = dictionary["timeRange"] as? String
        self.acceptCount = dictionary["acceptCount"] as! String
        self.bookedCount = dictionary["bookedCount"] as? String
        self.remain = dictionary["remain"] as! String
        self.disabled = dictionary["disabled"] as? String
        self.addressId = dictionary["addressId"] as? String
        self.address = dictionary["address"] as? String
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.scheduleId, forKey:"scheduleId")
        dictionary.setValue(self.timeRange, forKey:"timeRange")
        dictionary.setValue(self.acceptCount, forKey:"acceptCount")
        dictionary.setValue(self.bookedCount, forKey:"bookedCount")
        dictionary.setValue(self.remain, forKey:"remain")
        dictionary.setValue(self.disabled, forKey:"disabled")
        dictionary.setValue(self.addressId, forKey:"addressId")
        dictionary.setValue(self.address, forKey:"address")
        return dictionary
    }
    
    
}

/// 预约日程表
class QN_ScheduleList : QN_Base {
    
    private(set) var scheduleDate: String!     // 日前
    private(set) var date: String?    // 星期
    var list = [QN_Schedule]()                 // 日程列表
    
    
    required init!(_ dictionary: NSDictionary) {
        // 所需要的数据都存在，则开始真正的数据初始化
        self.scheduleDate = dictionary["scheduleDate"] as! String
        self.date = dictionary["date"] as? String
        if let list = dictionary["schedule"] as? NSArray {
            for obj in list {
                if let dic = obj as? NSDictionary, let message = QN_Schedule(dic) {
                    self.list.append(message)
                }
            }
        }
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        let list = NSMutableArray()
        for message in self.list {
            list.addObject(message.dictionary())
        }
        dictionary.setValue(list, forKey:"schedule")
        dictionary.setValue(self.scheduleDate, forKey:"scheduleDate")
        dictionary.setValue(self.date, forKey:"date")
        return dictionary
    }
    
    
}
