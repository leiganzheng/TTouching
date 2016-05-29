//
//  QD_Doctor.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit

/**
*  医生用户账号信息
*
*/
class QD_Doctor: QN_Base {
    
    private(set) var doctorId: String!          // 医生账号Id
    var doctorName: String?        // 医生名称
    private(set) var auth: String!              // 加密串（见公共参数）
    private(set) var phone: String?             // 电话
    
    var headPic: String?          // 头像名称
    var introduce: String?          // 个人简介
    private(set) var location: String?       // 所在地区
    private(set) var belongHospital: String?              // 所属医院
    private(set) var department_hospital: String?             // 所属科室
    private(set) var subscribe: Int?         // 预约数
    private(set) var comments: Int?        // 评论数
    private(set) var satisfaction: String?              // 满意度
    var identity: String?        // 身份证图片名称
    var goodDescribe: String?              // 擅长病症描述
    private(set) var isAvaliable: Int?              // 审核状态（0:审核不通过；1：审核通过，即  已认证；2：审核不通过）
    var certification: Int?              // 审核状态（0:未认证；1：已认证；2：认证中）
    var jobTitle: String?          //职称
    private(set) var proxyId: String?          //显示的id
    var workCard: String?          //工作证图片名称
    
    var illList: NSArray?             // 系统疾病
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "doctorId", "doctorName", "auth") {
            super.init(dictionary)
            return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        self.doctorId = dictionary["doctorId"] as! String
        self.doctorName = dictionary["doctorName"] as? String
        self.auth = dictionary["auth"] as! String
        self.phone = dictionary["phone"] as? String
        
        self.headPic = dictionary["headPic"] as? String
        self.introduce = dictionary["introduce"] as? String
        self.location = dictionary["location"] as? String
        self.belongHospital = dictionary["belongHospital"] as? String
        
        self.department_hospital = dictionary["department_hospital"] as? String
        self.subscribe = dictionary["subscribe"]?.integerValue
        self.comments = dictionary["comments"]?.integerValue
        self.satisfaction = dictionary["satisfaction"] as? String
        self.identity = dictionary["identity"] as? String
        self.goodDescribe = dictionary["goodDescribe"] as? String
        self.isAvaliable = dictionary["isAvaliable"]!.integerValue
        self.certification = dictionary["certification"]!.integerValue
        self.jobTitle = dictionary["jobTitle"] as? String
        self.proxyId = dictionary["proxyId"] as? String
        self.workCard = dictionary["workCard"] as? String
        self.illList = dictionary["illList"] as? NSArray
        
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        dictionary.setValue(self.doctorId, forKey:"doctorId")
        dictionary.setValue(self.doctorName, forKey:"doctorName")
        dictionary.setValue(self.auth, forKey:"auth")
        dictionary.setValue(self.phone, forKey:"phone")
        
        dictionary.setValue(self.belongHospital, forKey:"belongHospital")
        dictionary.setValue(self.headPic, forKey:"headPic")
        dictionary.setValue(self.introduce, forKey:"introduce")
        dictionary.setValue(self.location, forKey:"location")
        dictionary.setValue(self.department_hospital, forKey:"department_hospital")
        dictionary.setValue(self.subscribe, forKey:"subscribe")
        dictionary.setValue(self.comments, forKey:"comments")
        dictionary.setValue(self.satisfaction, forKey:"satisfaction")
        dictionary.setValue(self.proxyId, forKey:"proxyId")
        dictionary.setValue(self.isAvaliable, forKey:"isAvaliable")
        dictionary.setValue(self.certification, forKey:"certification")
        dictionary.setValue(self.jobTitle, forKey:"jobTitle")
        dictionary.setValue(self.identity, forKey:"identity")
        dictionary.setValue(self.goodDescribe, forKey:"goodDescribe")
        dictionary.setValue(self.workCard, forKey:"workCard")
        dictionary.setValue(self.illList, forKey:"illList")
        return dictionary
    }
    
    
}
