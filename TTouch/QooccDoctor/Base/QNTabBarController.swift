//
//  QNTabBarController.swift
//  QooccHealth
//
//  Created by 肖小丰 on 15/4/14.
//  Copyright (c) 2015年 Lei. All rights reserved.
//
let QNNotificationJMPAppointmentOrder = "QNNotificationJMPAppointmentOrder"
var isJMPAppointmentOrder = false
var JMPAppointmentOrderIndex = "0" // 0 新  1 中  2 完成

import UIKit
// 跳转到订单界面
// MARK: Tab 分组
private enum QNTabBarItem: Int {
    case Main = 0
    case Location = 1
    case Favite = 2
    case Voice = 3
    case Shake = 4
    
    // 对应的图片名
    var imageName: String {
        switch self {
        case .Main: return "Room_MasterRoom_icon"
        case .Location: return "T_Setup_Location_icon"
        case .Favite: return "Manage_Collect_icon"
        case .Voice: return "T_Setup_Voice_icon"
        case .Shake: return "T_Setup_Shack_icon"
        }
    }
}

/// MARK: - 底部工具控制器
class QNTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 修改底部工具条的字体和颜色
        self.tabBar.translucent = false
        self.tabBar.barTintColor = defaultLineColor
        self.tabBar.tintColor = UINavigationBar.appearance().tintColor
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(objects: [UIColor.blackColor(), UIFont.systemFontOfSize(10)], forKeys: [NSForegroundColorAttributeName,NSFontAttributeName]) as? [String : AnyObject], forState: .Normal)
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(objects: [UIColor(red: 141/255.0, green: 110/255.0, blue: 99/255.0, alpha: 1.0), UIFont.systemFontOfSize(10)], forKeys: [NSForegroundColorAttributeName,NSFontAttributeName]) as? [String : AnyObject], forState: .Selected)

        // 图标配置
        if let _ = self.tabBar.items {
            self.itemConfig(QNTabBarItem.Main, title: NSLocalizedString("主页", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Location, title: NSLocalizedString("定位", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Favite, title: NSLocalizedString("收藏", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Voice, title: NSLocalizedString("语音", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Shake, title: NSLocalizedString("摇摇", tableName: "Localization",comment:"jj"))
        }
////        self.messageCountChanged()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("messageCountChanged"), name: QNNotificationMessageCountChanged, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("jmpAppointmentOrderVc"), name: QNNotificationJMPAppointmentOrder, object: nil)//跳转到预约进度页
//        // 点击通知
//        if isJMPAppointmentOrder {
//            isJMPAppointmentOrder = false
//            for vc in NSArray(array: self.viewControllers!) {
////                if (vc as! UINavigationController).viewControllers[0] is AppointmentOrderViewController {
////                    self.selectedViewController = vc as? UIViewController
////                    self.selectedIndex == 1
////                }
//            }
//        }
    }
    
    /**
    配置Item
    
    :param: index     配置项
    :param: haveDot   是否需要小红点
    
    :returns: 被配置的Item
    */
    private func itemConfig(qnItem: QNTabBarItem, haveDot: Bool = false,title:NSString) -> UITabBarItem? {
        if let item = self.tabBar.items?[qnItem.rawValue] {
            let imageName = qnItem.imageName
            if let image = UIImage(named: imageName + "1"),
                let selectedImage = UIImage(named: imageName + "2") {
                if !haveDot {
                    item.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    item.title = title as String
                    item.selectedImage = selectedImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                }
                else {
                    item.image = self.imageAddDotView(image).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    item.selectedImage = self.imageAddDotView(selectedImage).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                }
            }
            return item
        }
        return nil
    }
    func refrushItem(){
        if let _ = self.tabBar.items {
            self.itemConfig(QNTabBarItem.Main, title: NSLocalizedString("主页", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Location, title: NSLocalizedString("定位", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Favite, title: NSLocalizedString("收藏", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Voice, title: NSLocalizedString("语音", tableName: "Localization",comment:"jj"))
            self.itemConfig(QNTabBarItem.Shake, title: NSLocalizedString("摇摇", tableName: "Localization",comment:"jj"))
        }

    }
    private func imageAddDotView(image: UIImage) -> UIImage {
        let imageView = UIImageView(image: image)
        
        let dotView = UIView(frame: CGRect(x: imageView.bounds.width - 8, y: imageView.bounds.height - 8, width: 8, height: 8))
        dotView.layer.masksToBounds = true
        dotView.layer.cornerRadius = dotView.bounds.width/2.0
        dotView.backgroundColor = UIColor(red: 251/255.0, green: 55/255.0, blue: 55/255.0, alpha: 1.0)
        imageView.addSubview(dotView)
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        imageView.layer.renderInContext(context!)
        let imageResult = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageResult
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 消息总数发生改变时候的处理办法
//    func messageCountChanged() {
//        self.itemConfig(QNTabBarItem.UserCenter, haveDot: (g_NotReadMyMessageCount > 0))
//    }

}
