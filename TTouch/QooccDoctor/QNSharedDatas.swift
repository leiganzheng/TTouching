//
//  QNSharedDatas.swift
//  QooccShow
//
//  Created by Leiganzheng on 14/10/31.
//  Copyright (c) 2014年 Private. All rights reserved.
//

/*!
 *  此文件中放置整个App共享的数据
 */
import UIKit
//import OpenUDID

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
var g_ip:String?
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
//private var _udid: String?
//var g_UDID: String {
//    if _udid == nil {
//        var udid = OpenUDID.value() as NSString
//        if udid.length > 32 {
//            udid = udid.substringToIndex(32)
//        }
//        _udid = udid as String
//    }
//    return _udid!
//}

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
let g_SecretKey = "TTouch"

public enum EquementSign: Int{
    
    case Light   = 0
    case Curtain = 1
    case Action  = 2
    case Air = 3
    case Controller  = 4
    case Security = 5
    case Music     = 6
    case Movie    = 7
    
//    init(str: String) {
//        switch str {
//        case "灯光":
//            self = Light
//        case "窗帘":
//            self = Curtain
//        case "动作":
//            self = Action
//        case "空调":
//            self = Air
//        case "监视":
//            self = Controller
//        case "保全":
//            self = Security
//        case "音乐":
//            self = Music
//        case "影视":
//            self = Movie
//        
//        default :
//            assert(false, "有未知str，不能转换成 EquementSign 枚举类型")
//            self = Light
//        }
//    }
//    
//    init(type: Int) {
//        switch type {
//        case 0:
//            self = Light
//        case 1:
//            self = Curtain
//        case 2:
//            self = Action
//        case 3:
//            self = Air
//        case 4:
//            self = Controller
//        case 5:
//            self = Security
//        case 6:
//            self = Music
//        case 7:
//            self = Movie
//        default :
//            assert(false, "有未知type（Int），不能转换成 EquementSign 枚举类型")
//            self = Light
//        }
//    }
//    
//    var titleString : String {
//        switch self {
//        case Light:
//            return "灯光"
//        case Curtain:
//            return "窗帘"
//        case Action:
//            return "动作"
//        case Air:
//            return "空调"
//        case Controller:
//            return "监视"
//        case Security:
//            return "保全"
//        case Music:
//            return "音乐"
//        case Movie:
//            return "影视"
//       
//        }
//    }
    
}



