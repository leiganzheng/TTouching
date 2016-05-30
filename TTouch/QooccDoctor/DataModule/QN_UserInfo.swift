//
//  QN_UserInfo.swift
//  QooccShow
//
//  Created by LiuYu on 14/11/6.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

import Foundation

/**
//MARK:- 用户信息
*/
class QN_UserInfo: QN_Base {
    
    private(set) var gId: String!            // 家庭号
    private(set) var userName: String!       // 用户名
    private(set) var ownerId: String!        // 用户唯一标识符
    var remark: String?         // 备注   Modify by LiuYu ! -> ? on 2015-7-14 （非必须的字段不要用 ? 
    private(set) var lastMeasureDate: String! //最后一次测量时间
    private(set) var photo: String?          // 用户头像Url
    private(set) var phone: String?             // 用户电话
    private(set) var signSumary: String?        //异常描述信息
    var starType: Int!        // 是否星标用户（1：true）
    var isChecked: Int!         // 消息是否已读 0：未读；1：已读
    private(set) var abnormalState: Int!     // 1 : 亚健康；2：不健康
    
//    private(set) var vipType: VipType! = .Normal// vip级别
    // Vip类型, NOTE:增加VIP等级的时候，要增加相应的VIP等级图片，格式在 image 计算属性中
//    enum VipType : Int {
//        case Normal = 0 // 普通用户
//        case VIP1 = 1   // VIP1
//        case VIP2 = 2   // VIP2
//        case VIP3 = 3   // VIP3
//        case VIP4 = 4   // VIP4
//        case VIP5 = 5   // VIP5
//        case VIP6 = 6   // VIP6
//        case VIP7 = 7   // VIP7
//        case VIP8 = 8   // VIP8
//        case VIP0 = 99  // VIP0
//        
//        var image : UIImage {
////            return UIImage(named: "VIP_" + String(self.rawValue))!
//        }
//    }

    static func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return ["gId":"gId",
                "userName":"userName",
                "ownerId":"ownerId",
                "vipLevel":"vipLevel",
                "remark":"remark",
                "lastMeasureDate":"lastMeasureDate",
                "photo":"photo",
                "phone":"phone",
                "signSumary":"signSumary",
                "starType":"starType",
                "isChecked":"isChecked",
                "abnormalState":"abnormalState"]
    }
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "gId", "userName", "ownerId") {
                super.init(dictionary)
                return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        self.gId = dictionary["gId"] as! String
        self.userName = dictionary["userName"] as! String
        self.ownerId = dictionary["ownerId"] as! String
        self.remark = dictionary["remark"] as? String
        self.lastMeasureDate = dictionary["lastMeasureDate"] as? String
        self.photo = dictionary["photo"] as? String
        self.phone = dictionary["phone"] as? String
        self.signSumary = dictionary["signSumary"] as? String
        self.starType = dictionary["starType"]?.integerValue ?? 0
        self.isChecked = dictionary["isChecked"]?.integerValue ?? 0
        self.abnormalState = dictionary["abnormalState"]?.integerValue ?? 0
        
//        if let vipTypeInt = dictionary["vipLevel"]?.integerValue, let vipType = VipType(rawValue: vipTypeInt) {
//            self.vipType = vipType
//        }
        
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        dictionary.setValue(self.gId, forKey:"gId")
        dictionary.setValue(self.userName, forKey:"userName")
        dictionary.setValue(self.ownerId, forKey:"ownerId")
        dictionary.setValue(self.remark, forKey:"remark")
        dictionary.setValue(self.lastMeasureDate, forKey:"lastMeasureDate")
        dictionary.setValue(self.photo, forKey:"photo")
        dictionary.setValue(self.phone, forKey:"phone")
        dictionary.setValue(self.signSumary, forKey:"signSumary")
        dictionary.setValue(self.starType, forKey:"starType")
        dictionary.setValue(self.isChecked, forKey:"isChecked")
        dictionary.setValue(self.isChecked, forKey:"abnormalState")
//        dictionary.setValue(String(self.vipType.rawValue), forKey:"vipType")
        return dictionary
    }
    
 
}