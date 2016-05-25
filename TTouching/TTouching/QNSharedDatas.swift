//
//  QNSharedDatas.swift
//  QooccShow
//
//  Created by LiuYu on 14/10/31.
//  Copyright (c) 2014年 Qoocc. All rights reserved.
//

/** 此文件中放置整个App共享的数据 */

import UIKit
import OpenUDID

/// 加密解密密钥
let g_SecretKey = "qoocc"

// MARK: - 账号 & 账号管理
private let kKeyAccount = ("Account" as NSString).encrypt(g_SecretKey)
/// 账号（登录成功的）
var g_Account: String? {
    return (getObjectFromUserDefaults(kKeyAccount) as? NSString)?.decrypt(g_SecretKey)
}

private let kKeyPassword = ("Password" as NSString).encrypt(g_SecretKey)
/// 密码（登录成功的）
var g_Password: String? {
    return (getObjectFromUserDefaults(kKeyPassword) as? NSString)?.decrypt(g_SecretKey)
}
/// 保存账号和密码
func saveAccountAndPassword(account: String, password: String?) {
    saveObjectToUserDefaults(kKeyAccount, value: (account as NSString).encrypt(g_SecretKey))
    if password == nil {
        cleanPassword()
    }
    else {
        saveObjectToUserDefaults(kKeyPassword, value: (password! as NSString).encrypt(g_SecretKey))
    }
}
/// 清除密码
func cleanPassword() {
    removeObjectAtUserDefaults(kKeyPassword)
}

/// 是否登录
var g_isLogin: Bool { return g_currentGroup != nil }
/// 当前组账号
var g_currentGroup: QN_Group?
/// 是否绑定家庭号
var g_isBinding: Bool { return g_currentGroup?.groupId != nil && g_currentGroup?.groupId != "0"}
/// 注册返回，用来判断是否绑定手机号
var g_currentLoginID: String?

private let kKeyCurrentUserIndex = ("CurrentUserIndex" as NSString).encrypt(g_SecretKey)
/// 当前的用户索引
var g_currentUserIndex: Int? = getObjectFromUserDefaults(kKeyCurrentUserIndex) as? Int {
didSet{
    if g_currentUserIndex == nil {
        removeObjectAtUserDefaults(kKeyCurrentUserIndex)
    }
    else {
        saveObjectToUserDefaults(kKeyCurrentUserIndex, value: g_currentUserIndex!)
    }
}
}
/// 当前用户信息
var g_currentUserInfo: QN_UserInfo? {
    return g_currentGroup?.currentUserInfo
}
// MARK: - 绑定成功通知
let QNNotificationBindingFamilySuccessed = "QNNotificationBindingFamilySuccessed"
// MARK: - 未读消息
/// 未读消息数改变发出此通知
let QNNotificationMessageCountChanged = "QNNotificationMessageCountChanged"
// MARK: 未读家庭消息
private let kKeyNotReadMyMessageCount = ("NotReadMyMessageCount" as NSString).encrypt(g_SecretKey)
/// 未读家庭消息
var g_NotReadMyMessageCount: Int = (getObjectFromUserDefaults(kKeyNotReadMyMessageCount) as? Int) ?? 0 {
didSet {
    saveObjectToUserDefaults(kKeyNotReadMyMessageCount, value: g_NotReadMyMessageCount)
    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMessageCountChanged, object: nil)
}
}

// MARK: 未读医疗建议消息
private let kKeyNotReadSuggestCount = ("NotReadSuggestCount" as NSString).encrypt(g_SecretKey)
/// 未读医疗建议消息
var g_NotReadSuggestCount: Int = (getObjectFromUserDefaults(kKeyNotReadSuggestCount) as? Int) ?? 0 {
didSet {
    saveObjectToUserDefaults(kKeyNotReadSuggestCount, value: g_NotReadSuggestCount)
    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMessageCountChanged, object: nil)
}
}

// MARK: 未读月报消息
private let kKeyNotReadMonthlyReportCount = ("NotReadMonthlyReportCount" as NSString).encrypt(g_SecretKey)
/// 未读月报消息
var g_NotReadMonthlyReportCount: Int = (getObjectFromUserDefaults(kKeyNotReadMonthlyReportCount) as? Int) ?? 0 {
didSet {
    saveObjectToUserDefaults(kKeyNotReadMonthlyReportCount, value: g_NotReadMonthlyReportCount)
    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMessageCountChanged, object: nil)
}
}

// MARK: 未读预约消息
private let kKeyNotReadScheduleMsgCount = ("kKeyNotReadScheduleCount" as NSString).encrypt(g_SecretKey)
/// 未读预约消息
var g_NotReadScheduleMsgCount: Int = (getObjectFromUserDefaults(kKeyNotReadScheduleMsgCount) as? Int) ?? 0 {
didSet {
    saveObjectToUserDefaults(kKeyNotReadScheduleMsgCount, value: g_NotReadScheduleMsgCount)
    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMessageCountChanged, object: nil)
}
}

// MARK: - 是否开启电话按钮
private let kKeyAllowShowPhone = ("AllowShowPhone" as NSString).encrypt(g_SecretKey)
/// 是否开启电话按钮
var g_AllowShowPhone: Bool = (getObjectFromUserDefaults(kKeyAllowShowPhone) as? Bool) ?? true {
didSet {
    saveObjectToUserDefaults(kKeyAllowShowPhone, value: g_AllowShowPhone)
}
}

// MARK: - 本地用户数据 （头像 & 昵称）
/// 设备对应的本地头像存储地址
let g_DeviceFacePath = String(format: "%@/Documents/%@.jpg",NSHomeDirectory(), g_UDID)

private let kKeyHeadImageUrl = ("HeadImageUrl" as NSString).encrypt(g_SecretKey)
/// 头像链接
var g_HeadImageUrl: String? = getObjectFromUserDefaults(kKeyHeadImageUrl) as? String {
didSet {
    if g_HeadImageUrl != nil {
        saveObjectToUserDefaults(kKeyHeadImageUrl, value: g_HeadImageUrl!)
    }
    else {
        removeObjectAtUserDefaults(kKeyHeadImageUrl)
    }
}
}

private let kKeyNickName = ("NickName" as NSString).encrypt(g_SecretKey)
/// 本地昵称
var g_NickName: String? = getObjectFromUserDefaults(kKeyNickName) as? String {
didSet {
    if g_NickName != nil {
        saveObjectToUserDefaults(kKeyNickName, value: g_NickName!)
    }
    else {
        removeObjectAtUserDefaults(kKeyNickName)
    }
}
}

// MARK: - UDID
private var _udid: String?
/// 设备唯一标识
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

// MARK: - DeviceToken
private let kKeyDeviceToken = ("DeviceToken" as NSString).encrypt(g_SecretKey)
/// DeviceToken 的本地保存
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






