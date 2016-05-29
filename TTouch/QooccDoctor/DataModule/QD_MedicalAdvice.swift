//
//  QD_MedicalAdvice.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/7.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
/**
*  医生建议模版
*
*/
class QD_MedicalAdvice: QN_Base {
    private(set) var doctorId: String!           // 医生Id
    private(set) var templateId: String!         // 模版id
    private(set) var content: String!              // 建议内容
    private(set) var title: String!              // 建议标题
    private(set) var type: String!              // 建议类型
    private(set) var modifyTime: String!              // 修改时间
    var isUnfold: Bool = false          // 是否展开，默认不展开
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "doctorId", "templateId", "content","title","modifyTime","type") {
            super.init(dictionary)
            return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        self.doctorId = dictionary["doctorId"] as! String
        self.templateId = dictionary["templateId"] as! String
        self.content = dictionary["content"] as! String
        self.title = dictionary["title"] as! String
        self.type = dictionary["type"] as! String
        self.modifyTime = dictionary["modifyTime"] as! String
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        dictionary.setValue(self.doctorId, forKey:"doctorId")
        dictionary.setValue(self.templateId, forKey:"templateId")
        dictionary.setValue(self.content, forKey:"content")
        dictionary.setValue(self.title, forKey:"title")
        dictionary.setValue(self.modifyTime, forKey:"modifyTime")
        dictionary.setValue(self.type, forKey:"type")
        return dictionary
        
    }
}
