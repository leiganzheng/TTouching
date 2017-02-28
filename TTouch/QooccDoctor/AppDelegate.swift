//
//  AppDelegate.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/3.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import IQKeyboardManager
let kKeyIsFirstStartApp = ("IsFirstStartApp" as NSString).encrypt(g_SecretKey) // 第一次启动判断的Key

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UIAlertViewDelegate{

    var window: UIWindow?
    var inder:String?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("\n<\(APP_NAME)> 开始运行\nversion: \(APP_VERSION)(\(APP_VERSION_BUILD))\nApple ID: \(APP_ID)\nBundle ID: \(APP_BUNDLE_ID)\n")
        // Override point for customization after application launch.
    

        // 开启拦截器
        QNInterceptor.start()
        UIApplication.sharedApplication().statusBarHidden = false
        UINavigationBar.appearance().barTintColor = appThemeColor
        UINavigationBar.appearance().tintColor = navigationBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
        
        if application.respondsToSelector(#selector(UIApplication.isRegisteredForRemoteNotifications)) {
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert, UIUserNotificationType.Badge], categories: nil))
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes([UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert, UIRemoteNotificationType.Badge])
        }
        let manager = IQKeyboardManager.sharedManager()
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldToolbarUsesTextFieldTintColor = true
        manager.enableAutoToolbar = false
        
        UIApplication.sharedApplication().applicationSupportsShakeToEdit = true
        //获取系统当前语言版本(中文zh-Hans,英文en)
        let def = NSUserDefaults.standardUserDefaults()
        let languages = def.valueForKey("AppleLanguages")
        let current = languages?.objectAtIndex(0) as! NSString
        let temp = def.valueForKey("userLanguage")
        if temp == nil {
            def.setValue(current, forKey: "userLanguage")
        }
        
        NSBundle.setLanguage(current as String)
        def.synchronize()//持久化，不加的话不会保存
        self.window?.canBecomeFirstResponder()
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    func applicationDidBecomeActive(application: UIApplication) {
        if SocketManagerTool.shareInstance().clientSocket != nil {
            if SocketManagerTool.shareInstance().clientSocket.isDisconnected {
                QNTool.enterLoginViewController()
            }
        }
        
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        DLog("didReceiveLocalNotification : \(notification)")
        if application.applicationState == .Active {
            if let dict = notification.userInfo {
                let identifier = dict["identifier"] as! String
                self.inder = identifier
                let alert = UIAlertView(title: NSLocalizedString("闹钟", tableName: "Localization",comment:"jj"), message: NSLocalizedString("是时候看看闹钟了", tableName: "Localization",comment:"jj"), delegate: nil, cancelButtonTitle: NSLocalizedString("取消", tableName: "Localization",comment:"jj"),otherButtonTitles:NSLocalizedString("确定", tableName: "Localization",comment:"jj"))
                alert.delegate = self
                alert.show()
            }
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            var dev_addr = 0
            var status = 97
            if getObjectFromUserDefaults("KZoneS" + self.inder!) != nil {
                let zoneStr = getObjectFromUserDefaults("KZoneS" + self.inder!) as! String
                dev_addr = Int(zoneStr)!
            }
            if getObjectFromUserDefaults("KSceneS" + self.inder!) != nil {
                let scene = getObjectFromUserDefaults("KSceneS" + self.inder!) as! Int
                status = scene
            }
            let command:Int = 36
            let dict = ["command": command, "dev_addr" : dev_addr, "dev_type": 2, "work_status":status]
            QNTool.openSence(dict)
            

        }
    }

}

