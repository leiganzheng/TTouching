//
//  QN_Order.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/9/8.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
/// 订单
class QN_Order: QN_Base {
    private(set) var orderNo: String!          // 订单号
    private(set) var name: String?        // 预约人
    private(set) var consultWay: String?              // 咨询方式
    private(set) var scheduleDate: String?             // 预约日期
    private(set) var timeRange: String?              // 预约时间（1:上午;2:下午;3:晚上）
    private(set) var dealStatus: String?             // 订单进度 0: 新订单; 1：进行中 2:已完成订单
    private(set) var time: String?              // 时间 （当新订单时，未订单支付时间；当进行中，为开始咨询时间；当完成订单，未结束咨询时间）
    private(set) var address: String?            // 预约地点
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "orderNo") {
            super.init(dictionary)
            return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        self.orderNo = dictionary["orderNo"] as! String
        self.name = dictionary["name"] as? String
        self.consultWay = dictionary["consultWay"] as? String
        self.scheduleDate = dictionary["scheduleDate"] as? String
        self.timeRange = dictionary["timeRange"] as? String
        self.dealStatus = String(format: "%i", dictionary["dealStatus"]!.integerValue)
        self.time = dictionary["time"] as? String
        self.address = dictionary["address"] as? String
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        dictionary.setValue(self.orderNo, forKey:"orderNo")
        dictionary.setValue(self.name, forKey:"name")
        dictionary.setValue(self.consultWay, forKey:"consultWay")
        dictionary.setValue(self.scheduleDate, forKey:"scheduleDate")
        dictionary.setValue(self.timeRange, forKey:"timeRange")
        dictionary.setValue(self.dealStatus, forKey:"dealStatus")
        dictionary.setValue(self.time, forKey:"time")
        dictionary.setValue(self.address, forKey:"address")
        return dictionary
    }

}
