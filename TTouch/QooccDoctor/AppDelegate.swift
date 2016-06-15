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
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("\n<\(APP_NAME)> 开始运行\nversion: \(APP_VERSION)(\(APP_VERSION_BUILD))\nApple ID: \(APP_ID)\nBundle ID: \(APP_BUNDLE_ID)\n")
        // Override point for customization after application launch.
        

        // 开启拦截器
        QNInterceptor.start()
        UIApplication.sharedApplication().statusBarHidden = false
        UINavigationBar.appearance().barTintColor = appThemeColor
        UINavigationBar.appearance().tintColor = navigationBackgroundColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
       
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }


}

