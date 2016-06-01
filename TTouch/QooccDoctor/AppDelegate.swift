//
//  AppDelegate.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/3.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
let kKeyIsFirstStartApp = ("IsFirstStartApp" as NSString).encrypt(g_SecretKey) // 第一次启动判断的Key

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IChatManagerDelegate{

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("\n<\(APP_NAME)> 开始运行\nversion: \(APP_VERSION)(\(APP_VERSION_BUILD))\nApple ID: \(APP_ID)\nBundle ID: \(APP_BUNDLE_ID)\n")
        // Override point for customization after application launch.
        
        // 更新 & 数据迁移
//        QNTool.update()
        
        // 开启拦截器
        QNInterceptor.start()
        
        // 自动显示app评论框
//        if !allowShowStartPages {
//            QNTool.autoShowCommentAppAlertView()
//        }
        
//        // 友盟统计
//        MobClick.startWithAppkey("559c76fd67e58e3b870028da")
//        MobClick.setLogEnabled(false)
//        
        // 极光推送相关服务
//        QNPushTool.startPushTool()
//        APService.setupWithOption(launchOptions)
//        QNPushTool.clear()

        // 修改导航栏样式
        UINavigationBar.appearance().barTintColor = appThemeColor
        UINavigationBar.appearance().tintColor = navigationBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
//        //配置环信sdk
//        EaseMob.sharedInstance().registerSDKWithAppKey("qoocc-develop#xite", apnsCertName: "")
//        EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
//        //设置环信委托
//        EaseMob.sharedInstance().chatManager.removeDelegate(self)
//        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
//        
//        if launchOptions != nil { //订单消息推送点击
//            if let remoteNotification = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary,let aps = remoteNotification["aps"] as? NSDictionary,let alert = aps["alert"] as? String {
//                if NSString(string: alert).rangeOfString("预约").location != NSNotFound {
//                    isJMPAppointmentOrder = true
//                    JMPAppointmentOrderIndex = "0"
//                } else if NSString(string: alert).rangeOfString("评价").location != NSNotFound {
//                    isJMPAppointmentOrder = true
//                    JMPAppointmentOrderIndex = "2"
//                }
//            }
//        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        EaseMob.sharedInstance().applicationDidEnterBackground(application)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        EaseMob.sharedInstance().applicationWillEnterForeground(application)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        EaseMob.sharedInstance().applicationWillTerminate(application)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        APService.registerDeviceToken(deviceToken)
        // 上传registrationId和deviceTok到我们的服务器
        g_deviceToken = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "")
            .stringByReplacingOccurrencesOfString(">", withString: "")
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        QNNetworkTool.uploadRegistrationIdAndToken()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        APService.handleRemoteNotification(userInfo)
        self.jmpForRemoteNotification(userInfo)
    }
    //IOS7
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        APService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.NewData)
        self.jmpForRemoteNotification(userInfo)
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        APService.showLocalNotificationAtFront(notification, identifierKey: nil)  //identifierKey用于过滤，nil表示全部通过
    }
    
    //MARK: - IChatManagerDelegate

    //登录状态变化,单点登录
    func didLoginFromOtherDevice() {
        EaseMob.sharedInstance().chatManager.asyncLogoffWithUnbindDeviceToken(false, completion: { (dict, error) -> Void in
            let alertView = UIAlertView(title: "提醒", message: "你的账号已在其他地方登录", delegate: nil, cancelButtonTitle: "确定")
            alertView.rac_buttonClickedSignal().subscribeNext({(indexNumber) -> Void in
                QNNetworkTool.logout()
            })
            alertView.show()
            }, onQueue: nil)
    }
    //MARK: - 推送跳转
    func jmpForRemoteNotification(userInfo: [NSObject : AnyObject]) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            if let aps = userInfo["aps"] as? NSDictionary,let alert = aps["alert"] as? String {
                if NSString(string: alert).rangeOfString("预约").location != NSNotFound {
                    JMPAppointmentOrderIndex = "0"
                    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationJMPAppointmentOrder, object: nil)
                } else if NSString(string: alert).rangeOfString("评价").location != NSNotFound {
                    JMPAppointmentOrderIndex = "2"
                    NSNotificationCenter.defaultCenter().postNotificationName(QNNotificationJMPAppointmentOrder, object: nil)
                }
            }
        }
    }
}

