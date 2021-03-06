//
//  QNInterceptor.swift
//  QooccHealth
//
//  Created by Leiganzheng on 15/5/28.
//  Copyright (c) 2015年 Leiganzheng. All rights reserved.
//

import Foundation
import Aspects
import IQKeyboardManager
private var g_qnInterceptor: QNInterceptor? = nil


// MARK: 遵循此协议的将会拦截
protocol QNInterceptorProtocol {}

// MARK: 遵循此协议的 ViewController 会在 viewWillAppear(animated: Bool) 的时候显示导航栏
protocol QNInterceptorNavigationBarShowProtocol: QNInterceptorProtocol {}

// MARK: 遵循此协议的 ViewController 会在 viewWillAppear(animated: Bool) 的时候隐藏导航栏
protocol QNInterceptorNavigationBarHiddenProtocol: QNInterceptorProtocol {}

// MARK: 遵循此协议的 ViewController 会支持 IQKeyboardManager 键盘遮挡解决方案
protocol QNInterceptorKeyboardProtocol: QNInterceptorProtocol {}

/**
*  @author Leiganzheng, 15-05-26 14:05:28
*
*  // MARK: - 拦截器，拦截遵循了QNInterceptorProtocol 协议的类的实例
*/
class QNInterceptor : NSObject {
    
    // MARK: 开始拦截
    class func start() {
        if g_qnInterceptor == nil {
            g_qnInterceptor = QNInterceptor()
        }
    }
    
    // 停止拦截
    class func stop() {
        g_qnInterceptor = nil
    }
    
    
    override init() {
        super.init()
        
        // MARK: 关闭键盘拦截器的Toolbar （ in IQKeyboardManager）
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        // MARK:- UIViewController
        // MARK: 拦截 UIViewController 的 loadView() 方法
        repeat {
            let block : @convention(block) (aspectInfo: AspectInfo) -> Void = { [weak self](aspectInfo: AspectInfo) -> Void in
                if let _ = self, let viewController = aspectInfo.instance() as? UIViewController where viewController is QNInterceptorProtocol {
                    // 设置统一的背景色
                    viewController.view.backgroundColor = defaultBackgroundGrayColor
                    // 修改基础配置
                    viewController.edgesForExtendedLayout = UIRectEdge.None
                    // 全部设置成返回按钮，在有导航栏，并且不是导航栏的rootViewController
                    if let rootViewController = viewController.navigationController?.viewControllers.first where rootViewController != viewController {
                        viewController.configBackButton()
                    }
                }
            }
        do {
           try UIViewController.aspect_hookSelector(#selector(UIViewController.loadView), withOptions: AspectOptions.PositionAfter, usingBlock: unsafeBitCast(block, AnyObject.self))
        }catch{
            
            }
        
        } while(false)
        
         //MARK: 拦截 UIViewController 的 viewDidLoad() 方法
        repeat { // 目前没有操作，所以不需要拦截
            let block : @convention(block) (aspectInfo: AspectInfo) -> Void = { [weak self](aspectInfo: AspectInfo) -> Void in
                if let _ = self, let viewController = aspectInfo.instance() as? UIViewController where viewController is QNInterceptorProtocol {
                   
                }
            }
            do {
                try UIViewController.aspect_hookSelector(#selector(UIViewController.viewDidLoad), withOptions: AspectOptions.PositionBefore, usingBlock: unsafeBitCast(block, AnyObject.self))
            }catch{
                    
                }
        } while(false)
        
        // MARK: 拦截 UIViewController 的 viewWillAppear(animated: Bool) 方法
        repeat {
            let block : @convention(block) (aspectInfo: AspectInfo) -> Void = { [weak self](aspectInfo: AspectInfo) -> Void in
                if let _ = self, let viewController = aspectInfo.instance() as? UIViewController where viewController is QNInterceptorProtocol {
                    // 修改导航栏的显示和隐藏
                    if viewController is QNInterceptorNavigationBarShowProtocol {
                        viewController.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
                    else if viewController is QNInterceptorNavigationBarHiddenProtocol {
                        viewController.navigationController?.setNavigationBarHidden(true, animated: true)
                    }
                    
                    // 键盘遮挡解决方案
                    if !(viewController is QNInterceptorKeyboardProtocol) {
//                        IQKeyboardManager.sharedManager().disableInViewControllerClass(viewController.classForCoder)
                    }
//                    viewController.navigationController?.navigationBar.translucent = false // 关闭透明度效果
//                    UIApplication.sharedApplication().statusBarHidden = false
//                    if (viewController is ForgetPasswordViewController || viewController is RegisterViewController || viewController is LanguageViewController || viewController is AboutViewController) {
//                        // 修改导航栏样式
//                        UINavigationBar.appearance().barTintColor = defaultBackgroundGrayColor
//                        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
//                        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
//                        
//                    }else{
//                        UINavigationBar.appearance().barTintColor = appThemeColor
//                        UINavigationBar.appearance().tintColor = navigationBackgroundColor
//                        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navigationTextColor, NSFontAttributeName: UIFont.systemFontOfSize(18)]
//                        
//                    }


                }
            }
            do {
                try UIViewController.aspect_hookSelector(#selector(UIViewController.viewWillAppear(_:)), withOptions: AspectOptions.PositionBefore, usingBlock: unsafeBitCast(block, AnyObject.self))
            }catch{
                
            }
          
        } while(false)
        
        // MARK: 拦截 UIViewController 的 viewWillDisappear(animated: Bool) 方法
        repeat {
            let block : @convention(block) (aspectInfo: AspectInfo) -> Void = { [weak self](aspectInfo: AspectInfo) -> Void in
                if let _ = self, let viewController = aspectInfo.instance() as? UIViewController where viewController is QNInterceptorProtocol {
                    viewController.view.endEditing(true)
                }
            }
            do {
                try UIViewController.aspect_hookSelector(#selector(UIViewController.viewWillDisappear(_:)), withOptions: AspectOptions.PositionBefore, usingBlock: unsafeBitCast(block, AnyObject.self))
            }catch{
                
            }
          
        } while(false)
        
        // MARK: 拦截 UIViewController 的 deinit/dealloc 方法，  可测试类是否被释放
//        do {
//            let block : @objc_block (aspectInfo: AspectInfo) -> Void = { [weak self](aspectInfo: AspectInfo) -> Void in
//                if let strongSelf = self, let viewController = aspectInfo.instance() as? UIViewController {
//                    println("控制器被释放:\(viewController.debugDescription)")
//                }
//            }
//            UIViewController.aspect_hookSelector(Selector("dealloc"), withOptions: AspectOptions.PositionBefore, usingBlock: unsafeBitCast(block, AnyObject.self), error: nil)
//        } while(false)
    }
    
    
}