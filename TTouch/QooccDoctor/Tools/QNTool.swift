//
//  QNTool.swift
//  QooccHealth
//
//  Created by Leiganzheng on 15/5/28.
//  Copyright (c) 2015年 Leiganzheng. All rights reserved.
//

import Foundation
import Reachability
private let qnToolInstance = QNTool()

/**
*  //MARK:- 通用工具类
*/
class QNTool: NSObject {
}

/**
*  @author Leiganzheng, 15-06-24
*
*  //MARK:- 更新时做 数据迁移
*/
private let kKeyVersionOnLastOpen = ("VersionOnLastOpen" as NSString).encrypt(g_SecretKey)
extension QNTool {
    class func update() {
        let versionOnLastOpen = (getObjectFromUserDefaults(kKeyVersionOnLastOpen) as? NSString)?.decrypt(g_SecretKey)
        if versionOnLastOpen == nil || compareVersion(versionOnLastOpen!, version2: APP_VERSION) != NSComparisonResult.OrderedSame { // 当没有设置最后一次打开的版本号，或者最后一次打开的版本号比当前版本号低的情况下要做更新操作
            
            // 当版本从低于或者等于2.0的时候，做下面的数据迁移
            if versionOnLastOpen == nil || compareVersion(versionOnLastOpen!, version2: "2.0") != NSComparisonResult.OrderedDescending {
                repeat { // 用户账号数据迁移，从老数据中获取账号，然后重新登录，需要用户设置密码
                    let key = "GROUP"
//                    if let groupDictionary = getObjectFromUserDefaults(key) as? NSDictionary, let group = QN_Group(groupDictionary) {
//                        saveAccountAndPassword(group.groupId, password: nil)
//                        removeObjectAtUserDefaults(key)
//                    }
                } while (false)
                
                // 删除被废弃的 key
                removeObjectAtUserDefaults("IsFirstStartApp")
                removeObjectAtUserDefaults("NotReadSystemMessageCount")
                removeObjectAtUserDefaults("NotReadHomeMessageCount")
                removeObjectAtUserDefaults("DeviceToken")
                removeObjectAtUserDefaults("AllowShowPhone")
                removeObjectAtUserDefaults("NotReadMonthlyReportCount")
                removeObjectAtUserDefaults("NotReadSuggestCount")
                removeObjectAtUserDefaults("CurrentUserIndex")
            }
            
            // 所有版本升级都需要做的操作
            repeat {
                removeObjectAtUserDefaults(kKeyIsFirstStartApp) // 清空第一次登录操作
            } while (false)
            
            // 所有操作完成后，更新最低版本号
            saveObjectToUserDefaults(kKeyVersionOnLastOpen, value: (APP_VERSION as NSString).encrypt(g_SecretKey))
        }
    }
}

/**
*  @author Leiganzheng, 15-05-28 15:05:50
*
*  //MARK:- 提示框相关
*/
extension QNTool {
    
    /**
    //MARK: 弹出会自动消失的提示框
    
    :param: message    提示内容
    :param: completion 提示框消失后的回调
    */
    class func showPromptView(message: String = "功能优化中，请稍后！", _ completion: (()->Void)? = nil) {
        lyShowPromptView(message, completion)
    }
    
    /**
    //MARK: 弹出进度提示框
    
    :param: message         提示内容
    :param: inView          容器，如果设置为nil，会放在keyWindow上
    :param: timeoutInterval 超时隐藏，如果设置为nil，超时时间是3min
    */
    class func showActivityView(message: String?, inView: UIView? = nil, _ timeoutInterval: NSTimeInterval? = nil) {
        lyShowActivityView(message, inView: inView, timeoutInterval)
    }
    
    /**
    //MARK: 隐藏进度提示框
    */
    class func hiddenActivityView() {
        lyHiddenActivityView()
    }
    
    /**
    //MARK: 显示错误提示
    
    优先显示服务器返回的错误信息，如果没有，则显示网络层返回的错误信息，如果在没有，则显示默认的错误提示
    
    :param: dictionary 服务器返回的Dic
    :param: error      网络层返回的error
    :param: errorMsg   服务器返回的错误信息
    */
    class func showErrorPromptView(dictionary: NSDictionary?, error: NSError?, errorMsg: String? = nil) {
        if errorMsg != nil {
            QNTool.showPromptView(errorMsg!); return
        }
        
        if let errorMsg = dictionary?["errorMsg"] as? String {
            QNTool.showPromptView(errorMsg); return
        }
        
        if error != nil && error!.domain.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            QNTool.showPromptView("网络异常，请检测网络设置！"); return
        }
        
        QNTool.showPromptView()
    }
    
    
}

/**
*  @author Leiganzheng, 15-06-11
*
*  //MARK:- 增加空提示的View
*/
private let kTagEmptyView = 96211
private let kTagMessageLabel = 96212
extension QNTool {
    class func showEmptyView(message: String? = nil, inView: UIView?) {
        if inView == nil { return }
        
        //
        var emptyView: UIView! = inView!.viewWithTag(kTagEmptyView)
        if emptyView == nil {
            emptyView = UIView(frame: inView!.bounds)
            emptyView.userInteractionEnabled = false
            emptyView.backgroundColor = UIColor.clearColor()
            emptyView.tag = kTagEmptyView
            inView!.addSubview(emptyView)
        }
        
        // 设置提示
        if message != nil {
            let widthMax = emptyView.bounds.width - 40
            var messageLabel: UILabel! = emptyView.viewWithTag(kTagMessageLabel) as? UILabel
            if messageLabel == nil {
                messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: widthMax, height: 20))
                messageLabel.tag = kTagMessageLabel
                messageLabel.textColor = tableViewCellDefaultDetailTextColor
                messageLabel.backgroundColor = UIColor.clearColor()
                messageLabel.textAlignment = .Center
                messageLabel.autoresizingMask = .FlexibleWidth
                messageLabel.numberOfLines = 0
                emptyView.addSubview(messageLabel)
            }
            
            messageLabel.text = message
            messageLabel.bounds = CGRect(origin: CGPointZero, size: messageLabel.sizeThatFits(CGSize(width: widthMax, height: CGFloat.max)))
            messageLabel.center = CGPoint(x: emptyView.bounds.width/2.0, y: emptyView.bounds.height/2.0)
        }
        else {
            emptyView.viewWithTag(kTagMessageLabel)?.removeFromSuperview()
        }
    }
    
    class func hiddenEmptyView(forView: UIView?) {
        forView?.viewWithTag(kTagEmptyView)?.removeFromSuperview()
    }
    
    
}

/**
*  @author Leiganzheng, 15-05-28 16:05:14
*
*  //MARK:- 页面切换相关
*/
extension QNTool {

    /**
    //MARK: 转场动画过渡
    
    :param: vc 将要打开的ViewController
    */
    class func enterRootViewController(vc: UIViewController, animated: Bool = true) {
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            let animationView = UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)
            appDelegate.window?.addSubview(animationView)
            let changeRootViewController = { () -> Void in
                appDelegate.window?.rootViewController = vc
                if animated {
                    appDelegate.window?.bringSubviewToFront(animationView)
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        animationView.transform = CGAffineTransformMakeScale(3.0, 3.0)
                        animationView.alpha = 0
                        }, completion: { (finished) -> Void in
                            animationView.removeFromSuperview()
                    })
                }
                else {
                    animationView.removeFromSuperview()
                }
            }
            
            if let viewController = appDelegate.window?.rootViewController where viewController.presentedViewController != nil {
                viewController.dismissViewControllerAnimated(false) {
                    changeRootViewController()
                }
            }
            else {
                changeRootViewController()
            }
        }
    }
    
    /**
    //MARK: 进入登陆的控制器
    */
    class func enterLoginViewController() {
        let vc = (UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()!)
        QNTool.enterRootViewController(vc)
    }
}

//MARK:- 获得某个范围内的屏幕图像
extension QNTool {
    class func imageFromView(view: UIView, frame: CGRect) -> UIImageView {
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        UIRectClip(frame)
        view.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        return  imageView
    }
}

//MARK:- 弹出APP评论框
//NOTE: 如果用户去评论了将不会弹出评论页面
private let kKeyTheRemainingNumberShowComment = ("TheRemainingNumberShowComment" as NSString).encrypt(g_SecretKey) // 显示评论剩余次数
private let theRemainingNumberShowCommentDefault = 10    // 设置成0，表示每次都会弹出评论提示，直到用户去评论，或者用户残忍拒绝。  设置成2，表示每相隔启动2次会弹出提示
private var theRemainingNumberShowComment: Int? {
get {
    return getObjectFromUserDefaults(kKeyTheRemainingNumberShowComment) as? Int ?? theRemainingNumberShowCommentDefault // 显示评论剩余次数，当该值 = -1的时候，表示已经评论过了，就不会在给出评论了,
}
set {
    if newValue == nil {
        removeObjectAtUserDefaults(kKeyTheRemainingNumberShowComment)
    }
    else {
        saveObjectToUserDefaults(kKeyTheRemainingNumberShowComment, value: newValue!)
    }
}
}
extension QNTool {
    class func showCommentAppAlertView() {
        let commentAlertView = UIAlertView(title: "程序员牺牲陪女神的时间，加班加点做出的产品，你狠心不给个评分吗？", message: nil, delegate: nil, cancelButtonTitle: "狠心拒绝")
        commentAlertView.addButtonWithTitle("去评分")
        commentAlertView.rac_buttonClickedSignal().subscribeNext({(indexNumber) -> Void in
            if let index = indexNumber as? Int {
                switch index {
                case 0: // 残忍拒绝
                    theRemainingNumberShowComment = nil
                case 1: // 去评论
                    theRemainingNumberShowComment = -1
                    UIApplication.sharedApplication().openURL(NSURL(string: APP_URL_IN_ITUNES)!)
                default: break
                }
            }
        })
        commentAlertView.show()
    }
    
    // 自动显示弹出App评论框
    class func autoShowCommentAppAlertView() {
        if let count = theRemainingNumberShowComment {
            switch count {
            case 0:
                self.showCommentAppAlertView()
            case Int.min..<0:
                return // 小于0 表示用户已经去评论过了，所有不在弹出App评论框
            default:
                theRemainingNumberShowComment = count - 1
            }
        }
    }
    
}

//MARK:- 判断当前网络状况
extension QNTool {
    //网络连接状态
    class func netWorkStatus() -> NetworkStatus {
        let netWorkStatic = Reachability.reachabilityForInternetConnection()
        netWorkStatic.startNotifier()
        return netWorkStatic.currentReachabilityStatus()
    }
}


// MARK: - 让 Navigation 支持右滑返回
extension QNTool: UIGestureRecognizerDelegate {
    
    /**
    让 Navigation 支持右滑返回
    
    :param: navigationController 需要支持的 UINavigationController 对象
    */
    class func addInteractive(navigationController: UINavigationController?) {
        navigationController?.interactivePopGestureRecognizer!.enabled = true
        navigationController?.interactivePopGestureRecognizer!.delegate = qnToolInstance
    }
    
    /**
    移除 Navigation 右滑返回
    
    :param: navigationController 需要支持的 UINavigationController 对象
    */
    class func removeInteractive(navigationController: UINavigationController?) {
        navigationController?.interactivePopGestureRecognizer!.enabled = false
        navigationController?.interactivePopGestureRecognizer!.delegate = nil
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        _ = topViewController()
        if let vc = topViewController() where gestureRecognizer == vc.navigationController?.interactivePopGestureRecognizer {
            return (vc.navigationController!.viewControllers.count > 1)
        }
        return false // 其他情况，则不支持
    }
    
    
}
// MARK: - 检查字符串的合法性
extension QNTool {
    /**
    检查字符串的合法性
    
    :param: string      源字符串
    :param: allowSpace  是否允许全空格
    :param: allowLength 合法字符串必须大于的长度
    */
    class func stringCheck(string: String?, allowAllSpace: Bool = false, allowLength: Int = 0) -> Bool {
        if let text = string where (allowAllSpace ? text : text.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions(), range: nil)).characters.count > allowLength {
            return true
        }
        return false
    }
}
// MARK: -
extension QNTool {
    class func modifyEqument(arr:NSArray) {//修改各设备的信息
        let dict = ["command": 31,"save_dev": arr]
        let sockertManger = SocketManagerTool.shareInstance()
        sockertManger.sendMsg(dict) { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("status") as! NSNumber
            if (status == 1){
                let d = arr[0] as! NSDictionary
                let address = d.objectForKey("dev_addr") as! String
                let name = d.objectForKey("dev_name") as! String
                
                DBManager.shareInstance().updateName(name, type: address)
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改成功！")
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改失败！")
            }

        }
        
    }
    func UTF8ToGB2312(str: String) -> NSData? {
        let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
        
        let data = str.dataUsingEncoding(enc, allowLossyConversion: false)
        
        return data
    }
}
//MARK: - 
extension QNTool {
   class func openSence(dict: NSDictionary) {
    print(dict)
        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
            
            let d = result as! NSDictionary
            let status = d.objectForKey("work_status") as! Int
            if (status == 17){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启总控情景一！")
            }else if(status == 18){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启总控情景二！")
            }else if (status == 19){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启总控情景三！")
            }else if (status == 20){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启总控情景四！")
            }else if (status == 21){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启总控情景五！")
            }else if (status == 31){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "关闭所有设备！")
            }else if(status == 97){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景一！")
            }else if (status == 98){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景二！")
            }else if (status == 99){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景三！")
            }else if (status == 100){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景四！")
            }else if (status == 110){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启所有设备！")
            }else if (status == 111){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "关闭所有设备！")
            }
            else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
            }
            
        })
    }
    class func openLight(d: Device,value:Int ) {
        var dict:NSDictionary = [:]
        let command = 36
        let dev_addr = Int(d.address!)
        let dev_type:Int = (d.dev_type)!
        var msg = ""
        if dev_type == 3 {
            if value == 0 {
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":0]
//                print(dict)
                msg = "关闭调光"
            }else if(value>0&&value<24){//调光
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":value]
                msg = "调光\(value/100)"
//                print(dict)
                
            }else if(value == 99){
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":99]
                msg = "最大亮度"
                
            }
             SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status >= 0 && status <= 99){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
        }
        if dev_type == 8 {
            if value == 0 {
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":223]
                msg = "关闭调光"
            }else if(value>0&&value<24){//调光一档
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":209]
                msg = "调光一档"
                
            }else if(value>=25&&value<50){//调光二档
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":210]
                msg = "调光二档"
                
            }
            else if(value>=50&&value<75){//调光三档
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":211]
                msg = "调光三档"
                
            }
            else if(value>=75&&value<99){//调光四档
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":212]
                msg = "调光四档"
                
            }else if(value == 99){
                dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":222]
                msg = "最大亮度"
                
            }
             SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 223 || status == 209 || status == 210 || status == 211 || status == 212 || status == 222){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
        }

    }
    class func openDLight(d: Device,slider:UISlider ) {
        var dict:NSDictionary = [:]
        let command = 36
        let dev_addr = Int(d.address!)
        let dev_type:Int = (d.dev_type)!
        var msg = ""
        if dev_type == 4 {
            if slider.tag == 100 {
                slider.minimumValue = 100
                slider.maximumValue = 199
                if slider.value == 100   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":100]
                    msg = "关闭左回路"
                    print(dict)
                }else if(slider.value>100&&slider.value<199){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":Int(slider.value)]
                    msg = "调光中"
                    print(dict)
                    
                }else if(slider.value == 199 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":199]
                    msg = "最大亮度"
                    
                }
                SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue >= 0 && status.intValue <= 99){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
            }else if (slider.value == 101){
                slider.minimumValue = 200
                slider.maximumValue = 299
                if slider.value == 200   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":200]
                    msg = "关闭右回路"
                }else if(slider.value>200&&slider.value<299){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 299 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":199]
                    msg = "最大亮度"
                    
                }
                SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue >= 0 && status.intValue <= 99){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
            }
        }else if(dev_type == 9){//老版本
            if slider.tag == 100 {
                slider.minimumValue = 264
                slider.maximumValue = 268
                if slider.value == 264   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":264]
                    msg = "关闭左回路"
                }else if(slider.value>264&&slider.value<268){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 268 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":199]
                    msg = "最大亮度"
                    
                }
                SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue > 264 && status.intValue < 268){
                        //停止调光
                        dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":8]
                        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                            
                        })
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else if (status.intValue > 264 || status.intValue < 268){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }
                    else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
                
            }else if (slider.value == 101){
                slider.minimumValue = 384
                slider.maximumValue = 448
                if slider.value == 384   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":384]
                    msg = "关闭左回路"
                }else if(slider.value>384&&slider.value<448){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 448 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":448]
                    msg = "最大亮度"
                    
                }
                SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue > 384 && status.intValue < 448){
                        //停止调光
                        dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":128]
                        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                            
                        })
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else if (status.intValue > 384 || status.intValue < 448){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }
                    else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
                
            }
        }

    }
    class func openCutain(d: Device,value:Int ) {
        let command = 36
        let dev_addr = Int(d.address!)
        let dev_type:Int = d.dev_type!
        var dict:NSDictionary = [:]
        if value == 0 {
            dict = ["command": command,"dev_addr" :dev_addr!,"dev_type":dev_type,"work_status":192]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 192){
                    QNTool.showPromptView("打开左路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        
        }else if (value == 1){
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":224]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 224){
                    QNTool.showPromptView("长按左路窗帘开")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
                 })
    
        }else if (value == 2){
           
             dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":144]
             SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 144){
                    QNTool.showPromptView("暂停左路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        }else if (value == 3){
            
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":128]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 128){
                    QNTool.showPromptView("关闭左路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })

            
        }else if (value == 4){
            
             dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":160]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 160){
                    QNTool.showPromptView("长按左路窗帘关")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        }else if (value == 5){
            
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":12]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 12){
                    QNTool.showPromptView("打开右路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        }else if (value == 6){
            
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":14]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 14){
                    QNTool.showPromptView("长按左路窗帘开")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        }else if (value == 7){
            
             dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":9]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 9){
                    QNTool.showPromptView("暂停右路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })

        }else if (value == 8){
            
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":8]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 8){
                   QNTool.showPromptView("关闭右路窗帘")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })

        }else if (value == 9){
            
             dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":10]
            SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! Int
                if (status == 10){
                    QNTool.showPromptView("长按右路窗帘关")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
        }
    }

}

// MARK: -
extension QNTool {
    class func configCell(device:Device,tableView:UITableView)->UITableViewCell{
        let d = device
        if d.dev_type == 3{//单回路调光控制端
            let cellIdentifier = "MSigleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
            }
            cell.titel.setTitle(d.dev_name!, forState: .Normal)
            cell.slider.addTarget(self, action:#selector(SixPaternViewController.valueChanged(_:)), forControlEvents: .ValueChanged)
            return cell
        }else if d.dev_type == 4{//双回路调光控制端
            let cellIdentifier = "MDoubleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
            }
            cell.title.setTitle(d.dev_name!, forState: .Normal)
            cell.slider1.addTarget(self, action: #selector(SixPaternViewController.dSliderValueChanged(_:)), forControlEvents: .ValueChanged)
            cell.slider2.addTarget(self, action: #selector(SixPaternViewController.dSliderValueChanged(_:)), forControlEvents: .ValueChanged)
            
            return cell
        }else if d.dev_type == 5{//三回路开关控制端
            let cellIdentifier = "MThreeTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
            }
            cell.title.setTitle(d.dev_name!, forState: .Normal)
            return cell
        }else if d.dev_type == 6{//六回路开关控制端
            let cellIdentifier = "MSixTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSixTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSixTableViewCell
            }
            cell.title.setTitle(d.dev_name!, forState: .Normal)
            return cell
        }else if d.dev_type == 7{//窗帘控制端
            let cellIdentifier = "MCurtainTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MCurtainTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MCurtainTableViewCell
            }
            cell.LTitle.text=d.dev_name!
            cell.L1.addTarget(self, action: #selector(SixPaternViewController.open1(_:)), forControlEvents: .TouchUpInside)
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SixPaternViewController.longOpen1(_:)))
            longGesture.minimumPressDuration = 0.8
            cell.L1.addGestureRecognizer(longGesture)
            cell.L2.addTarget(self, action: #selector(SixPaternViewController.stop1(_:)), forControlEvents: .TouchUpInside)
            cell.L3.addTarget(self, action: #selector(SixPaternViewController.close1(_:)), forControlEvents: .TouchUpInside)
            return cell
        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            let cellIdentifier = "MSigleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSigleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSigleTableViewCell
            }
            return cell
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            let cellIdentifier = "MDoubleTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDoubleTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDoubleTableViewCell
            }
            return cell
        }else if d.dev_type == 10{//三/六回路开关控制端
            let cellIdentifier = "MThreeTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MThreeTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MThreeTableViewCell
            }
            cell.title.setTitle(d.dev_name!, forState: .Normal)
            return cell
        }else if d.dev_type == 11{
            let cellIdentifier = "MSixTouchTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MSixTouchTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MSixTouchTableViewCell
            }
            cell.title.setTitle(d.dev_name!, forState: .Normal)
            return cell
        }else if d.dev_type == 12{//空调
            let cellIdentifier = "MAirTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MAirTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MAirTableViewCell
            }
            return cell
        }
        else if d.dev_type == 13{//地暖
            let cellIdentifier = "MDiNuanTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MDiNuanTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MDiNuanTableViewCell
            }
            return cell
        }
        else if d.dev_type == 14{//新风
            let cellIdentifier = "MXinFenTableViewCell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! MXinFenTableViewCell!
            if cell == nil {
                cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! MXinFenTableViewCell
            }
            return cell
        }else{
            return UITableViewCell()
        }

    }
}

extension QNTool {

    class func initUserLanguage()->NSBundle{
        let def = NSUserDefaults.standardUserDefaults()
        var string = def.valueForKey("userLanguage") as! NSString
        if(string.length == 0){
            //获取系统当前语言版本(中文zh-Hans,英文en)
            
            let languages = def.valueForKey("AppleLanguages")
            
            let current = languages?.objectAtIndex(0) as! NSString
            
            string = current
            def.setValue(current, forKey: "userLanguage")
            def.synchronize()//持久化，不加的话不会保存
        }
        //获取文件路径
        let path = NSBundle.mainBundle().pathForResource(string as String, ofType: "lproj")
        if (path != nil) {
             return NSBundle(path: path!)!
        }
        return NSBundle()
       
    }
    class func userLanguage()-> NSString{
        let def = NSUserDefaults.standardUserDefaults()
        var string = def.valueForKey("userLanguage") as! NSString
        if(string.length == 0){
            //获取系统当前语言版本(中文zh-Hans,英文en)
            let languages = def.valueForKey("AppleLanguages")
            let current = languages?.objectAtIndex(0) as! NSString
            string = current
            def.setValue(current, forKey: "userLanguage")
            def.synchronize()//持久化，不加的话不会保存
            return current
        }
        return string
    }
    class func setUserLanguage(language:NSString){
         let def = NSUserDefaults.standardUserDefaults()
        def.setValue(language, forKey: "userLanguage")
        def.synchronize()
    }
}
