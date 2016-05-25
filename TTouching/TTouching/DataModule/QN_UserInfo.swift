//
//  QN_UserInfo.swift
//  QooccShow
//
//  Created by LiuYu on 14/11/6.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

import Foundation

/// 用户信息，一个账户下可以有多个用户
class QN_UserInfo: QN_BaseDataModel, QN_DataModelProtocol {
    
    private(set) var id: String!            // 用户Id
    private(set) var name: String!          // 用户名
    private(set) var age: Int!          // 年龄
    private(set) var sex: Int!          // 性别
    private(set) var remark: String!          // 描述
    private(set) var area: String!          // 地区
    private(set) var address: String!          // 地址
    private(set) var appellation: String!          // 家庭称谓
    private(set) var accountNumber: String! // 用户唯一标识符
    private(set) var num: Int!              // 用户在账户中顺序
    private(set) var vip: Int!              // 0:非vip,1:vip1
    
    var photoURL: String?          // 用户头像Url
    private(set) var suggestNumber: Int!        // 用户建议数量
    private(set) var reportNumber: Int!         // 用户回复数量
    private(set) var weeklyReportNumber: Int!   // 用户每周
    private(set) var phone: String?             // 用户电话
    
    private(set) var illnessHistoryType : String?   // 既往病史
    private(set) var userPatientType: String?      // 用户类型
    private(set) var idCard : String?              // 身份证
    private(set) var healthCard : String?          //  健康卡
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_BaseDataModel.existValue(dictionary, "id", "name", "accountNumber", "num", "vip") {
                super.init(dictionary)
                return nil
        }
        
        // 所需要的数据都存在，则开始真正的数据初始化
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.accountNumber = dictionary["accountNumber"] as! String
        self.num = dictionary["num"]!.integerValue
        
        self.age = dictionary["age"]!.integerValue
        self.sex = dictionary["sex"]!.integerValue
        self.remark = dictionary["remark"] as! String
        self.area = dictionary["area"] as! String
        self.address = dictionary["address"] as! String
        self.appellation = dictionary["appellation"] as! String
        
        self.vip = dictionary["vip"]!.integerValue
        
        self.photoURL = dictionary["photoURL"] as? String
        self.suggestNumber = dictionary["suggestNumber"]?.integerValue ?? 0
        self.reportNumber = dictionary["reportNumber"]?.integerValue ?? 0
        self.weeklyReportNumber = dictionary["weeklyReportNumber"]?.integerValue ?? 0
        self.phone = dictionary["phone"]?.description
        
        self.illnessHistoryType = dictionary["illnessHistoryType"] as? String
        self.userPatientType = dictionary["userPatientType"] as? String
        self.idCard = dictionary["idCard"] as? String
        self.healthCard = dictionary["healthCard"] as? String
      
        super.init(dictionary)
    }
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.id, forKey:"id")
        dictionary.setValue(self.name, forKey:"name")
        
        dictionary.setValue(self.age, forKey:"age")
        dictionary.setValue(self.sex, forKey:"sex")
        dictionary.setValue(self.remark, forKey:"remark")
        dictionary.setValue(self.area, forKey:"area")
        dictionary.setValue(self.address, forKey:"address")
        dictionary.setValue(self.appellation, forKey:"appellation")
        
        dictionary.setValue(self.accountNumber, forKey:"accountNumber")
        dictionary.setValue(self.num, forKey:"num")
        dictionary.setValue(self.vip, forKey:"vip")
        
        dictionary.setValue(self.photoURL, forKey:"photoURL")
        dictionary.setValue(self.suggestNumber, forKey:"suggestNumber")
        dictionary.setValue(self.reportNumber, forKey:"reportNumber")
        dictionary.setValue(self.weeklyReportNumber, forKey:"weeklyReportNumber")
        dictionary.setValue(self.phone, forKey:"phone")
        
        dictionary.setValue(self.illnessHistoryType, forKey:"illnessHistoryType")
        dictionary.setValue(self.userPatientType, forKey:"userPatientType")
        dictionary.setValue(self.idCard, forKey:"idCard")
        dictionary.setValue(self.healthCard, forKey:"healthCard")
        return dictionary
    }
    
 
}