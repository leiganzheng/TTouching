//
//  QNSharedDatas.swift
//  QooccShow
//
//  Created by LiuYu on 14/10/31.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

/*!
 *  此文件中放置整个App共享的数据
 */
import UIKit
import OpenUDID

//MARK:- 账号 & 账号管理
//MARK: 账号（登录成功的）
private let kKeyAccount = ("Account" as NSString).encrypt(g_SecretKey)
var g_Account: String? {
    return (getObjectFromUserDefaults(kKeyAccount) as? NSString)?.decrypt(g_SecretKey)
}
//MARK: 密码（登录成功的）
private let kKeyPassword = ("Password" as NSString).encrypt(g_SecretKey)
var g_Password: String? {
    return (getObjectFromUserDefaults(kKeyPassword) as? NSString)?.decrypt(g_SecretKey)
}
//MARK: 保存账号和密码
func saveAccountAndPassword(account: String, password: String?) {
    saveObjectToUserDefaults(kKeyAccount, value: (account as NSString).encrypt(g_SecretKey))
    if password == nil {
        cleanPassword()
    }
    else {
        saveObjectToUserDefaults(kKeyPassword, value: (password! as NSString).encrypt(g_SecretKey))
    }
}
//MARK: 清除密码
func cleanPassword() {
    removeObjectAtUserDefaults(kKeyPassword)
}

//MARK: 当前账户信息有变更时的通知
var g_isLogin: Bool { return g_doctor != nil }    // 是否登录
//MARK: g_doctor 当登录账号
var g_doctor: QD_Doctor?
//MARK: g_currentUser 当选中用户
var g_currentUser: QN_UserInfo?


//MARK:- 未读消息数改变发出此通知
let QNNotificationMessageCountChanged = "QNNotificationMessageCountChanged"
//MARK:- 未读家庭消息
private let kKeyNotReadMyMessageCount = ("NotReadMyMessageCount" as NSString).encrypt(g_SecretKey)
var g_NotReadMyMessageCount: Int = (getObjectFromUserDefaults(kKeyNotReadMyMessageCount) as? Int) ?? 0 {
didSet {
    saveObjectToUserDefaults(kKeyNotReadMyMessageCount, value: g_NotReadMyMessageCount)
    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMessageCountChanged, object: nil)
}
}

//MARK:- 是否开启电话按钮
private let kKeyAllowShowPhone = ("AllowShowPhone" as NSString).encrypt(g_SecretKey)
var g_AllowShowPhone: Bool = (getObjectFromUserDefaults(kKeyAllowShowPhone) as? Bool) ?? true {
didSet {
    saveObjectToUserDefaults(kKeyAllowShowPhone, value: g_AllowShowPhone)
}
}

//MARK:- UDID
private var _udid: String?
var g_UDID: String {
    if _udid == nil {
        var udid = OpenUDID.value() as NSString
        if udid.length > 32 {
            udid = udid.substringToIndex(32)
        }
        _udid = udid as String
    }
    return _udid!
}

//MARK:- DeviceToken
private let kKeyDeviceToken = ("DeviceToken" as NSString).encrypt(g_SecretKey)
var g_deviceToken: String? = getObjectFromUserDefaults(kKeyDeviceToken) as? String {
didSet {
    if g_deviceToken != nil {
        saveObjectToUserDefaults(kKeyDeviceToken, value: g_deviceToken!)
    }
    else {
        removeObjectAtUserDefaults(kKeyDeviceToken)
    }
}
}
//MARK:-环信
private let kKeyHxpass = ("Hxpass" as NSString).encrypt(g_SecretKey)
var g_hxpass: String? = getObjectFromUserDefaults(kKeyHxpass) as? String {
didSet {
    if g_deviceToken != nil {
        saveObjectToUserDefaults(kKeyHxpass, value: g_hxpass!)
    }
    else {
        removeObjectAtUserDefaults(kKeyHxpass)
    }
}
}

//MARK:- 加密解密密钥
let g_SecretKey = "qoocc"




