//
//  QN_Group.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/8.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import Foundation

/// 用户组，一个用户组下面会有多个用户
class QN_Group: QN_BaseDataModel, QN_DataModelProtocol {
    
    // NOTE:增加VIP等级的时候，要增加相应的VIP等级图片，格式在 image 计算属性中, VIPx 对应的具体值要跟后台确认
    /// Vip类型,
    enum VipType : Int {
        case Normal = 0
        case VIP1 = 1
        case VIP2 = 2
        case VIP3 = 3
        case VIP4 = 4
        case VIP5 = 5
        case VIP6 = 6
        case VIP7 = 7
        case VIP8 = 8
        case VIP0 = 99
        
        var image : UIImage {
            return UIImage(named: "VIP_" + String(self.rawValue))!
        }
    }
    var communityId : String?      // 增加  communityId,不为空，表示是社区用户。
    var groupId: String!           // 账号Id（可以用来判断是否绑定家庭号,0:代表没有绑定）
    private(set) var gId: String!               // 群组唯一标识 后续申请
    private(set) var auth: String!              // 加密串（见公共参数）
    private(set) var vipType: VipType! = .Normal// vip级别
    private(set) var count: Int!                // 用户数量
    var users = [QN_UserInfo]()    // 用户信息
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
        if !QN_BaseDataModel.existValue(dictionary, "groupId", "gId", "count", "users", "auth") {
            super.init(dictionary)
            return nil
        }
        // 所需要的数据都存在，则开始真正的数据初始化
        g_currentLoginID = dictionary["loginId"] as? String
        self.groupId = dictionary["groupId"] as! String
        self.communityId = dictionary["communityId"] as? String
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
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.communityId, forKey:"communityId")
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
*  @author LiuYu, 15-04-27 09:04:49
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
        g_currentUserIndex = self.currentUserIndex  // 当前用户的话，需保持到本地
    }
    
    
}