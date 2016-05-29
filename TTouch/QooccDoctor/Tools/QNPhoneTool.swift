//
//  QNPhoneTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/5/11.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import Foundation

private let sharedPhoneTool = QNPhoneTool()

/**
*  @author LiuYu, 15-05-11 18:05:46
*
*  电话控制工具
*/
class QNPhoneTool: NSObject {
    
    /// 控制电话工具的显示和隐藏
    static var hidden: Bool = false {
        didSet {
            if !hidden && g_AllowShowPhone {
                SUNButtonBoard.defaultButtonBoard().startRunning()
            }
            else {
                SUNButtonBoard.defaultButtonBoard().stopRunning()
            }
        }
    }
    
    /**
    安装电话按钮
    */
    class func setup() {
        sharedPhoneTool
        
        let phoneButton = SUNButtonBoard.defaultButtonBoard()
        phoneButton.boardSelectedImage = "iphoneIcon_selected"
        phoneButton.boardImageString = "iphoneIcon_normal"
        phoneButton.autoPosition = true
        phoneButton.setBoardPosition(CGPointMake(240, 400), animate: false)
        phoneButton.boardSize = 74
    }

    
    override init() {
        super.init()

        // 对全局电话进行监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("tel:"), name: SUNButtonBoarButtonClickNotification, object: nil)
    }
 
    // 电话按钮被
    func tel(notification: NSNotification) {
        QNStatistical.statistical(QNStatisticalName.BDDHAN)
        if let phone =  g_currentUser?.phone, let phoneUrl = NSURL(string: "tel://" + phone) where phone != "" {
            let iphoneAlertView = UIAlertView(title: "确认要拨打" + g_currentUser!.userName + "的电话吗？", message: "电话：" + phone, delegate: nil, cancelButtonTitle: "取消")
            iphoneAlertView.addButtonWithTitle("确认")
            iphoneAlertView.rac_buttonClickedSignal().subscribeNext({ (indexNumber) -> Void in
                if indexNumber as? Int != 0 {
                    if !UIApplication.sharedApplication().openURL(phoneUrl) {
                        let alert = UIAlertView(title: "", message: "无法打开程序", delegate: nil, cancelButtonTitle: "确认")
                        alert.show()
                    }
                }
                })
            
            iphoneAlertView.show()
            return
        }
        QNTool.showPromptView("暂没有提供电话号码")
    }

    
}