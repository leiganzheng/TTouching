//
//  QN_Case.swift
//  QooccHealth
//
//  Created by leiganzheng on 15/8/31.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
/// 病历本的病历模型
class QN_Case: QN_BaseDataModel, QN_DataModelProtocol {
    
    var name: String!          // 姓名
    var gender: String?     // 病历所属人性别（1 男 2 女 3 其他）
    var age: String?          // 年龄
    var contact: String?          // 病历所属人联系方式
    var idCard : String?          // 身份证
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_BaseDataModel.existValue(dictionary, "name") {
            super.init(dictionary)
            return nil
        }
        
        // 所需要的数据都存在，则开始真正的数据初始化
        self.name = dictionary["name"] as! String
        self.gender = dictionary["gender"] as? String
        self.age = dictionary["age"] as? String
        
        self.contact = dictionary["contact"] as? String
        self.idCard = dictionary["idCard"] as? String
        super.init(dictionary)
    }
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.name, forKey:"name")
        dictionary.setValue(self.gender, forKey:"gender")
        dictionary.setValue(self.age, forKey:"age")
        
        dictionary.setValue(self.contact, forKey:"contact")
        dictionary.setValue(self.idCard, forKey:"idCard")
        return dictionary
    }
}