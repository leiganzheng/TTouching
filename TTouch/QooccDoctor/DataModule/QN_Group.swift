//
//  QN_Group.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/8.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import Foundation

/**
*  用户账号信息，一个账户下可以有多个用户
*  2.1 版中增加 用户头像和昵称
*/
class QN_Group : QN_Base {
    
    // Vip类型, NOTE:增加VIP等级的时候，要增加相应的VIP等级图片，格式在 image 计算属性中
    enum VipType : Int {
        case Normal = 0 // 普通用户
        case VIP1 = 1   // VIP1
        case VIP2 = 2   // VIP2
        case VIP3 = 3   // VIP3
        case VIP4 = 4   // VIP4
        case VIP5 = 5   // VIP5
        case VIP6 = 6   // VIP6
        case VIP7 = 7   // VIP7
        case VIP8 = 8   // VIP8
        case VIP0 = 99  // VIP0
        
        var image : UIImage {
            return UIImage(named: "VIP_" + String(self.rawValue))!
        }
    }
    
    private(set) var groupId: String!           // 账号Id
    private(set) var gId: String!               // 群组唯一标识 后续申请
    private(set) var auth: String!              // 加密串（见公共参数）
    private(set) var vipType: VipType! = .Normal// vip级别
    private(set) var count: Int!                // 用户数量
    private(set) var users = [QN_UserInfo]()    // 用户信息
    var currentUserIndex: Int = 0   // 当前活跃用户索引
    var isTest: Bool = false        // 是否是测试账号，测试账号是不会保存到本地，并且每次都需要登录
    var showId: String {            // 显示Id
        return self.isTest ? "测试账号" : self.groupId
    }
    var currentUserInfo: QN_UserInfo? {
        if self.currentUserIndex >= 0 && self.currentUserIndex < self.users.count {
            return self.users[self.currentUserIndex]
        }
        return nil
    }
    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "groupId", "gId", "count", "users", "auth") {
            super.init(dictionary)
            return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        self.groupId = dictionary["groupId"] as! String
        self.gId = dictionary["gId"] as! String
        self.auth = dictionary["auth"] as! String
        if let vipTypeInt = dictionary["vipType"]?.integerValue, let vipType = VipType(rawValue: vipTypeInt) {
            self.vipType = vipType
        }
        self.count = dictionary["count"]!.integerValue
        if let currentUserIndex = dictionary["currentUserIndex"] as? Int {
            self.currentUserIndex = currentUserIndex
        }
        for userInfoDictionary in dictionary["users"] as! NSArray {
            if let dictionary = userInfoDictionary as? NSDictionary, let user = QN_UserInfo(dictionary) {
                self.users.append(user)
            }
        }
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        dictionary.setValue(self.groupId, forKey:"groupId")
        dictionary.setValue(self.gId, forKey:"gId")
        dictionary.setValue(self.auth, forKey:"auth")
        dictionary.setValue(String(self.vipType.rawValue), forKey:"vipType")
        dictionary.setValue(self.count, forKey:"count")
        dictionary.setValue(self.currentUserIndex, forKey:"currentUserIndex")
        let users = NSMutableArray()
        for userInfo in self.users {
            users.addObject(userInfo.dictionary())
        }
        dictionary.setValue(users, forKey: "users")
        return dictionary
        
    }
    
    
}


/**
*  @author LeiGanZheng, 15-04-27 09:04:49
*
*  //MARK:- 切换用户行为的扩展
*/
extension QN_Group {
    
    /**
    //MARK: 选择用户
    
    :param: index 用户在用户组中的索引位置
    
    :returns: 如果不能切换用户则返回flase
    */
    func selectUser(index: Int) -> Bool {
        if index >= 0 && index < self.count {
            self.currentUserIndex = index
            self.selectedAction()
            return true
        }
        return false
    }
    
    /**
    //MARK: 下一个用户，如果不能切换用户则返回flase
    */
    func selectNextUser() -> Bool {
        if self.users.count <= 1 { return false }
        self.currentUserIndex = (self.currentUserIndex + 1)%self.users.count
        self.selectedAction()
        return true
    }
    
    /**
    //MARK: 上一个用户，如果不能切换用户则返回flase
    */
    func selectLastUser() -> Bool {
        if self.users.count <= 1 { return false }
        self.currentUserIndex = (self.currentUserIndex + self.users.count - 1)%self.users.count
        self.selectedAction()
        return true
    }
    
    /**
    切换用户完成后的一些操作
    */
    private func selectedAction() {
//        g_currentUserIndex = self.currentUserIndex  // 当前用户的话，需保持到本地
    }
    
    
}