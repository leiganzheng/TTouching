
//
//  QNPushTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/23.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import Foundation

private let sharedPushTool = QNPushTool()

//MARK: 收到消息的通知
let QNNotificationReceviedMessage = "QNNotificationReceviedMessage"
//MARK: 实时数据更新
let QNNotificationMedicalDataUpdate = "QNNotificationMedicalDataUpdate"
//MARK: 返现任务更新
let QNNotificationTaskUpdate = "QNNotificationTaskUpdate"

/**
*  极光推送接受管理器
*/
class QNPushTool : NSObject {
    
    // 开启极光推送数据的监听
    class func startPushTool() {
        sharedPushTool
    }
    
    //MARK: 清零
    class func clear() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        APService.resetBadge()  // 极光推送登录成功就清零Badge
    }
    
    override init() {
        super.init()
        
        // 监听极光推送的通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jpushDidSetup:"), name: kJPFNetworkDidSetupNotification, object: nil)            // 建立连接
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jpushDidClose:"), name: kJPFNetworkDidCloseNotification, object: nil)            // 关闭连接
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jpushDidRegister:"), name: kJPFNetworkDidRegisterNotification, object: nil)      // 注册成功
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jpushDidLogin:"), name: kJPFNetworkDidLoginNotification, object: nil)            // 登录成功
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jpushDidReceiveMessage:"), name: kJPFNetworkDidReceiveMessageNotification, object: nil) // 收到消息(非APNS)
        
        // 向系统注册推送
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            //可以添加自定义categories
            //3.创建UIUserNotificationSettings，并设置消息的显示类类型
            let userSetting = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge , UIUserNotificationType.Sound ,UIUserNotificationType.Alert]
                , categories: nil)
            
            //4.注册推送
            APService.registerForRemoteNotificationTypes(userSetting.types.rawValue, categories: nil)
        }
//        else {
//            //categories 必须为nil
//            APService.registerForRemoteNotificationTypes([UIRemoteNotificationType.Badge , UIRemoteNotificationType.Sound , UIRemoteNotificationType.Alert].rawValue, categories: nil)
//        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: JPush Notification
    func jpushDidSetup(notification: NSNotification) {
        print("极光推送 建立连接")
        QNNetworkTool.uploadRegistrationIdAndToken()
    }
    
    func jpushDidClose(notification: NSNotification) {
        print("极光推送 关闭连接")
    }
    
    func jpushDidRegister(notification: NSNotification) {
        print("极光推送 注册成功")
        QNNetworkTool.uploadRegistrationIdAndToken()
    }
    
    func jpushDidLogin(notification: NSNotification) {
        print("极光推送 登录成功")
        QNNetworkTool.uploadRegistrationIdAndToken()
        QNPushTool.clear()
    }
    
    func jpushDidReceiveMessage(notification: NSNotification) {
        //        println("极光推送 收到消息(非APNS)")
        if !g_isLogin { return } // 必须登录才处理
        if let userInfo = notification.userInfo,
            let content = userInfo["content"] as? String,
            let data = content.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
          {
             let dictionaryAll:NSDictionary?
                do {
                    dictionaryAll = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                }catch _{
                    dictionaryAll = nil
                }
            if dictionaryAll != nil {
                if let _ = dictionaryAll!["m"] as? NSDictionary,let type = Int((dictionaryAll!["t"] as? String)!)
                {
                    switch type {
                        //                case 101:
                        //                    if let message = QN_Message(dictionary) {
                        //                        println("极光推送 收到消息(非APNS) 解析成功 。。 收到IM消息")
                        //                        g_NotReadMyMessageCount++
                        //                        NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationReceviedMessage, object: message)
                        //                    }
                        //                case 601:
                        //                    println("极光推送 收到消息(非APNS) 解析成功 。。 收到系统未读数更新")
                        //                    QNNetworkTool.updateMyMessageNotReadCount()
                        //                case 602:
                        //                    println("极光推送 收到消息(非APNS) 解析成功 。。 收到实时测量数据")
                        //                    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationMedicalDataUpdate, object: dictionary)
                        //                case 603:
                        //                    println("极光推送 收到消息(非APNS) 解析成功 。。 收到系统未读医疗建议更新")
                        //                    if g_currentUserInfo!.id == (dictionary["ownerId"] as? String), let noread = (dictionary["unRead"] as? String)?.toInt() where g_NotReadSuggestCount != noread {
                        //                        g_NotReadSuggestCount = noread
                        //                    }
                        //                case 606:
                        //                    println("极光推送 收到消息(非APNS) 解析成功 。。 收到返现任务更新")
                        //                    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationTaskUpdate, object: dictionary)
                    case 610:
                        print("极光推送 收到消息(非APNS) 解析成功 。。 收到预约信息提醒")
                    default:
                        print("极光推送 收到消息(非APNS) 解析成功 。。 有未知的t:\(type)")
                    }
                }
                
            }
            
        }
    }
    
    
}