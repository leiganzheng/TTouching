//
//  QNNetworkTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/8.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
import Alamofire
/// 服务器地址
private let kServerAddress = { () -> String in
//    "http://xite.qoocc.com/dc"          // 正式环境
//    "http://v2.xite.qoocc.com"          // v2测试环境
    "http://192.168.20.133:7080/dc"     // 测试环境
//    "http://test.xite.qoocc.com/dc"     // 测试环境 Added by 肖小丰 2015-6-5
//    "http://108.109.110.111"
}()


// MARK:网络处理中心
class QNNetworkTool: NSObject {
}

// MARK: - 网络基础处理
private extension QNNetworkTool {
    
    /**
    生产共有的 URLRequest，如果是到巨细的服务器请求数据，必须使用此方法创建URLRequest
    
    :param: url    请求的地址
    :param: method 请求的方式， Get Post Put ...
    */
    private class func productRequest(url: NSURL!, method: NSString!) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        
        request.addValue(g_currentGroup?.auth ?? "", forHTTPHeaderField: "AUTH") // 用户身份串,在调用/api/login 成功后会返回这个串;未登录时为空
        request.addValue("1", forHTTPHeaderField: "AID")                // app_id, iphone=1, android=2
        request.addValue(APP_VERSION, forHTTPHeaderField: "VER")        // 客户端版本号
        request.addValue(g_UDID, forHTTPHeaderField: "CID")             // 客户端设备号
        request.addValue("2", forHTTPHeaderField: "CTYPE")              //版本类型: 1 或者不传，公众版; 2 社区版
        request.HTTPMethod = method as String
        return request
    }
    
    /**
    后台返回的数据错误，格式不正确 的 NSError
    */
    private class func formatError() -> NSError {
        return NSError(domain: "后台返回的数据错误，格式不正确", code: 10087, userInfo: nil)
    }
    
    /**
    Request 请求通用简化版
    
    :param: url               请求的服务器地址
    :param: method            请求的方式 Get/Post/Put/...
    :param: parameters        请求的参数
    :param: completionHandler 请求完成后的回掉， 如果 dictionary 为nil，那么 error 就不可能为空
    */
    private class func requestForSelf(url: NSURL?, method: String, parameters: [String : AnyObject]?, completionHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, dictionary: NSDictionary?, error: NSError?) -> Void) {
        request(ParameterEncoding.URL.encode(self.productRequest(url, method: method), parameters: parameters).0).response {
            do  {
                let errorJson: NSErrorPointer = nil
                let jsonObject: AnyObject? = try  NSJSONSerialization.JSONObjectWithData($2!, options: NSJSONReadingOptions.MutableContainers)
                var dictionary = jsonObject as? NSDictionary
                if dictionary == nil {  // Json解析结果出错
                    completionHandler(request: $0!, response: $1, data: $2, dictionary: nil, error: NSError(domain: "JSON解析错误", code: 10086, userInfo: nil)); return
                }
                
                // 这里有可能对数据进行了jsonData的包装，有可能没有进行jsonData的包装
                if let jsonData = dictionary!["jsonData"] as? NSDictionary {
                    dictionary = jsonData
                }
                
                let errorCode = Int((dictionary!["errorCode"] as! String))
                if errorCode == 1000 || errorCode == 0 {
                    completionHandler(request: $0!, response: $1, data: $2, dictionary: dictionary, error: nil)
                }
                else {
                    completionHandler(request: $0!, response: $1, data: $2, dictionary: dictionary, error: NSError(domain: "服务器返回错误", code:errorCode ?? 10088, userInfo: nil))
                }
                if dictionary == nil {  // Json解析结果出错
                    completionHandler(request: $0!, response: $1, data: $2, dictionary: nil, error: errorJson.memory); return
                }
            }catch {
                // 直接出错了
                completionHandler(request: $0!, response: $1, data: $2, dictionary: nil, error: $3); return
            }
            
        }
    }
    /**
    Get请求通用简化版
    
    :param: urlString         请求的服务器地址
    :param: parameters        请求的参数
    :param: completionHandler 请求完成后的回掉
    */
    private class func requestGET(urlString: String, parameters: [String : AnyObject]?, completionHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?,  dictionary: NSDictionary?, error: NSError?) -> Void) {
        let url: NSURL! = NSURL(string: urlString)
        assert((url != nil), "输入的url有问题")
        requestForSelf(url, method: "Get", parameters: parameters, completionHandler: completionHandler)  
    }
    
    /**
    Post请求通用简化版
    
    :param: urlString         请求的服务器地址
    :param: parameters        请求的参数
    :param: completionHandler 请求完成后的回掉
    */
    private class func requestPOST(urlString: String, parameters: [String : AnyObject]?, completionHandler: (request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?,  dictionary: NSDictionary?, error: NSError?) -> Void) {
        let url: NSURL! = NSURL(string: urlString)
        assert((url != nil), "输入的url有问题")
        requestForSelf(url, method: "POST", parameters: parameters, completionHandler: completionHandler)
    }
    
    /**
    将输入参数转换成字符传
    */
    private class func paramsToJsonDataParams(params: [String : AnyObject]) -> [String : AnyObject] {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            return ["jsonData" : jsonDataString]
        }catch{
            return ["jsonData" : ""]
        }
    }
}

// MARK: - 网络基础处理(上传)
extension QNNetworkTool {
    
    /**
    生产一个用于上传的Request
    
    :param: url      上传的接口的地址
    :param: method   上传的方式， Get Post Put ...
    :param: data     需要被上传的数据
    :param: fileName 上传的文件名
    */
    private class func productUploadRequest(url: NSURL!, method: NSString, data: NSData, fileName: NSString) -> NSURLRequest {
        let request = self.productRequest(url, method: method)
        // 定制一post方式上传数据，数据格式必须和下面方式相同
        let boundary = "abcdefg"
        request.setValue(String(format: "multipart/form-data;boundary=%@", boundary), forHTTPHeaderField: "Content-Type")
        // 注意 ："face"这个字段需要看文档服务端的要求，他们要取该字段进行图片命名
        let str = NSMutableString(format: "--%@\r\nContent-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",boundary, "face", fileName, "application/octet-stream")
        // 配置内容
        let bodyData = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) as! NSMutableData
        bodyData.appendData(data)
        bodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        bodyData.appendData(NSString(format: "--%@--\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        request.HTTPBody = bodyData
        return request
    }
    //生产多参数上传Request
    private class func uploadRequest(url: NSURL!, method: NSString, data: NSData, fileName: NSString,type: NSString) -> NSURLRequest {
        let request = self.productRequest(url, method: method)
        // 定制一post方式上传数据，数据格式必须和下面方式相同
        let boundary = "abcdefg"
        request.setValue(String(format: "multipart/form-data;boundary=%@", boundary), forHTTPHeaderField: "Content-Type")
        let str1 = NSMutableString(format: "--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",boundary, "type", type)
        let str = NSMutableString(format: "%@--%@\r\nContent-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\nContent-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n",str1,boundary, "img", fileName, "application/octet-stream")
        // 配置内容
        let bodyData = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) as! NSMutableData
        bodyData.appendData(data)
        bodyData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        bodyData.appendData(NSString(format: "--%@--\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        request.HTTPBody = bodyData
        return request
    }
}

// MARK: - 登录 & 登出 & 注册
extension QNNetworkTool {
    /**
    登录
    
    :param: groupId       登录Id
    :param: groupPassword 登录密码
    :param: completion    请求完成后的回掉
    */
    private class func login(GroupId groupId: String, GroupPassword groupPassword: String, completion: (QN_Group?, NSError?, String?,Int?) -> Void) {
        requestPOST(kServerAddress + "/api/login", parameters: paramsToJsonDataParams(["groupId" : groupId, "groupPassword" : groupPassword])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 2015 {
                    //表示 需要先绑定家庭号 才可以使用。 需要跳转到绑定家庭号页面。
                    if  let loginId: AnyObject = dictionary?["loginId"]! {
                        g_currentLoginID = "\(loginId)"
                    }
                    completion(nil, nil, dictionary!["errorMsg"] as? String,errorCode)
                }else  if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 2000 {
                    //表示 必须要用手机号登陆。 需要跳转到注册或者绑定页面。
                }else  if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    //修改 -by haijie 用户昵称  头像  获取修改
                    if let group = QN_Group(dictionary!) {
                        // 本地头像和昵称与服务器同步
                        if let headImageUrl = dictionary?["face"] as? String where  headImageUrl.characters.count > 1 {
                            g_HeadImageUrl = headImageUrl
                        }
                        else {
                            g_HeadImageUrl = nil
                        }
                        
                        if let nickName = dictionary?["nickName"] as? String where  nickName.characters.count > 0 {
                            g_NickName = nickName
                        }
                        else {
                            g_NickName = nil
                        }
                        completion(group, nil, nil,nil)
                    }else {
                        if  let loginId: AnyObject = dictionary?["loginId"]! {
                            g_currentLoginID = "\(loginId)"
                        }
                        completion(nil, self.formatError(), dictionary!["errorMsg"] as? String,nil)
                    }
                }else{
                     completion(nil, error, dictionary!["errorMsg"] as? String,nil)
                }
                
            }
            else {
                completion(nil, error, nil,nil)
            }
        }
    }
    
    /**
    登录，并且拥有页面跳转功能
    
    :param: groupId       登录Id
    :param: groupPassword 登录密码
    :param: isTest        是否是测试账号
    */
    class func login(GroupId groupId: String, GroupPassword groupPassword: String, isTest: Bool = false) {
        QNTool.showActivityView("正在登录...")
        QNNetworkTool.login(GroupId: groupId, GroupPassword: groupPassword) { (group, error, errorMsg,errorCode) -> Void in
            QNTool.hiddenActivityView()
            if group != nil {
                g_currentGroup = group
                g_currentGroup!.isTest = isTest
                if g_currentUserIndex != nil && g_currentUserIndex < g_currentGroup!.count {
                    g_currentGroup!.currentUserIndex = g_currentUserIndex!
                }
                if !isTest { // 请求成功，保存账号密码到本地(  测试账号不保存）
                    saveAccountAndPassword(groupId, password: groupPassword)
                }
                QNNetworkTool.uploadRegistrationIdAndToken()
                QNNetworkTool.updateApplyNotReadCount()
                QNNetworkTool.updateMyMessageNotReadCount()
                UIApplication.sharedApplication().statusBarHidden = false
                let mainStory = UIStoryboard(name: "Main", bundle: nil)
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                let vc = mainStory.instantiateViewControllerWithIdentifier("QNTabBarController")
                QNTool.enterRootViewController(vc)
                QNTool.autoShowEditNickNameView()
            } else if errorCode != nil && errorCode == 2015 {
                //跳转到绑定家庭组
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    if let viewController = appDelegate.window?.rootViewController  {
                        let vc = (BindingIDViewController.CreateFromStoryboard("Login") as? BindingIDViewController)!
                        vc.flag = true
                        vc.finished = { () -> Void in
                            QNNetworkTool.login(GroupId: groupId, GroupPassword: groupPassword)
                        }
                        viewController.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)

                    }
                }
            } else if errorCode != nil && errorCode == 2000 {
                //手机号登录
            } else {
                 QNTool.showErrorPromptView(nil, error: error, errorMsg: errorMsg)
            }
        }
    }
    
    /**
    更新用户信息
    */
    class func updateCurrentGroupInfo(completion: ((Bool) -> Void)?) {
        if !g_currentGroup!.isTest, let account = g_Account, let password = g_Password {
            QNNetworkTool.login(GroupId: account, GroupPassword: password) { (group, error, errorMsg,errorCode) -> Void in
                if group != nil {
                    g_currentGroup = group
                    g_currentGroup!.isTest = false
                    QNNetworkTool.uploadRegistrationIdAndToken()
                    completion?(true)
                }
                else {
                    completion?(false)
                    if errorMsg != nil && errorMsg?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1 {
                        completion?(false)
                        let commentAlertView = UIAlertView(title: "密码已修改，请重新登录！", message: nil, delegate: nil, cancelButtonTitle:nil)
                        commentAlertView.addButtonWithTitle("好")
                        commentAlertView.rac_buttonClickedSignal().subscribeNext({(indexNumber) -> Void in
                            QNNetworkTool.logout()
                        })
                        commentAlertView.show()

                    }
                }
            }
        }
    }
    
    /**
    退出登录，并且拥有页面跳转功能
    */
    class func logout() {
        g_currentUserIndex = nil
        g_currentGroup = nil
        cleanPassword()
        QNPhoneTool.hidden = true
        QNTool.enterLoginViewController()
    }
    /**
    用户注册
    
    :param: contact       手机号
    :param: password     登录密码
    :param: familyDoctor  家庭医生ID
    :param: code        验证码
    */
    class func registered(contact: String,password: String,code: String,familyDoctor: String, completion: (succeed : Bool, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/register", parameters: paramsToJsonDataParams(["contact" : contact,"password" : password,"authcode" : code,"familyDoctor" : familyDoctor])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                var succeed : Bool
                if let data = dictionary!["data"] as? NSDictionary {
                    succeed = true
                    let loginId: AnyObject = data["loginId"]! 
                    g_currentLoginID = "\(loginId)"
                }
                else {
                    succeed = false
                }
                completion(succeed: succeed, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
    获取注册验证码
    
    :param: contact      手机号
    */
    class func registeredSmscode(contact: String, completion: (succeed : Bool, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/smscode", parameters: paramsToJsonDataParams(["contact" : contact])) { (_, _, _, dictionary, error) -> Void in
            
            let succeed: Bool
            if dictionary != nil {
                if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 0 {
                    succeed = true
                }
                else {
                    succeed = false
                }
                completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
            }else {
                succeed = false
                completion(succeed: succeed, error, nil)
            }
        }
    }
    /**
    找回密码-获取短信验证码
    
    :param: phoneNum      手机号
    */
    class func getCheckcode(phoneNum: String, completion: (succeed : Bool, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/checkcode", parameters: paramsToJsonDataParams(["phoneNum" : phoneNum])) { (_, _, _, dictionary, error) -> Void in
            let succeed: Bool
            if dictionary != nil {
                if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 1000 {
                    succeed = true
                }
                else {
                    succeed = false
                }
            }else {
                succeed = false
            }
            completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
        }
    }
    
    /**
    找回密码
    
    :param:phone :     帐号
    :param:authcode :  验证码；
    :param:password :  新的密码；
    */
    class func findPwd(phone: String,authcode: String,password: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        let params = paramsToJsonDataParams(["phone" : phone,"authcode" : authcode,"password" : password])
        requestPOST(kServerAddress + "/api/user/findpwd", parameters: params) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                completion(dictionary, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
}

// MARK: - 绑定家庭号
extension QNNetworkTool {
    /**
    绑定家庭号
    
    :param: login_id       注册成功时返回的用户ID
    :param: groupId        家庭号
    :param: groupPassword  家庭号密码
    */
    class func bindGroup(loginId: String,groupPassword: String,groupId: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/bindGroup", parameters: paramsToJsonDataParams(["loginId" : loginId,"groupId" : groupId,"groupPassword" : groupPassword])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil,let group = QN_Group(dictionary!) {
                    g_currentGroup = group
                    g_currentGroup!.isTest = false
                    if g_currentUserIndex != nil && g_currentUserIndex < g_currentGroup!.count {
                        g_currentGroup!.currentUserIndex = g_currentUserIndex!
                    }
                    QNNetworkTool.uploadRegistrationIdAndToken()
                    QNNetworkTool.updateApplyNotReadCount()
                    QNNetworkTool.updateMyMessageNotReadCount()
                    completion(dictionary, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
     绑定用户和硬件
     
     :param:  imei    硬件IMEI
     :param:  userId  用户ID
     */
    class func bindHardware(imei: String,userId: String, completion: (NSInteger?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/bindHardware", parameters: paramsToJsonDataParams(["imei" : imei,"userId" : userId])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil,let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                completion(dictionary!["communityId"] as? NSInteger, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
     通过身份证绑定或创建用户
     
     :param:  login_id       注册成功时返回的用户ID
     :param:  idCard ： 身份证
     :param:  name：姓名

     */
    class func createOrBindUser(loginId: String,idCard: String,name: String, completion: (QN_Group?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/createOrBindUser", parameters: paramsToJsonDataParams(["idCard" : idCard,"loginId" : loginId,"name":name])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    //修改 -by haijie 用户昵称  头像  获取修改
                    if let group = QN_Group(dictionary!) {
                        // 本地头像和昵称与服务器同步
                        if let headImageUrl = dictionary?["face"] as? String where  headImageUrl.characters.count > 1 {
                            g_HeadImageUrl = headImageUrl
                        }
                        else {
                            g_HeadImageUrl = nil
                        }
                        
                        if let nickName = dictionary?["nickName"] as? String where  nickName.characters.count > 0 {
                            g_NickName = nickName
                        }
                        else {
                            g_NickName = nil
                        }
                        completion(group, nil, nil)
                    }else {
                        if  let loginId: AnyObject = dictionary?["loginId"]! {
                            g_currentLoginID = "\(loginId)"
                        }
                        completion(nil, self.formatError(), dictionary!["errorMsg"] as? String)
                    }
                }else{
                    completion(nil, error, dictionary!["errorMsg"] as? String)
                }
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
     通过身份证查找用户
     
     :param:  idCard    身份证号
     :param:  name  用户名字
     */
    class func findById(name: String,idCard: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/findById", parameters: paramsToJsonDataParams(["name" : name,"idCard" : idCard])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil{
                completion(dictionary, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }

    /// 解绑家庭号
    class func unbindGroup(completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/unBindGroup", parameters: nil) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                g_currentUserIndex = nil
                g_currentGroup?.groupId = "0"
                completion(dictionary, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
     获取用户绑定的硬件列表
     
     :param: userId： 用户Id
     :param: content
     */

    class func hardwareList(userId:String,completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/hardwareList", parameters: paramsToJsonDataParams(["userId":userId])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil,let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                completion(dictionary!["list"] as? NSArray, nil, nil)
            }else {
                completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
     解绑硬件
     
     :param: userId： 用户Id
     :param: content
     */
    
    class func unbindHardware(userId:String,imei:String,completion: (Bool?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/unbindHardware", parameters: paramsToJsonDataParams(["userId":userId,"imei":imei])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil,let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                completion(true, nil, nil)
            }else {
                completion(false, self.formatError(), dictionary?["errorMsg"] as? String)
            }
        }
    }


    /**
    评价咨询服务
    
    :param: orderNo      订单号
    :param: level   2 非常满意   1 满意   -1 不满意
    :param: content
    */
    class func orderContent(orderNo: String,level: String,content : String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/order/comment", parameters: paramsToJsonDataParams(["orderNo" : orderNo,"level" : level,"content" : content])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary,nil,nil)
        }
    }
    /**
    确认咨询结束
    
    :param: orderNo      订单号
    :param: orderInfo    可选，是否需要返回orderInfo，0:不返回;1:返回，默认为0
    */
    class func bindGroup(orderNo: String,orderInfo: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/order/confirm", parameters: paramsToJsonDataParams(["orderNo" : orderNo,"orderInfo" : orderInfo])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary,nil,nil)
        }
    }
    /**
    获取订单信息
    
    :param: orderNo        订单号
    :param: type            (可选）是否需要返回支付信息 0:不需要;1:需要 默认为0
    :param: comment        (可选）是否需要返回评价信息 0:不需要;1:需要 默认为0
    */
    class func getOrderInfo(orderNo: String,pay: String,completion: (NSDictionary?, NSError?) -> Void) {
        requestPOST(kServerAddress + "/api/order/info", parameters: paramsToJsonDataParams(["orderNo" : orderNo,"type" : pay])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                completion(dictionary, nil)
            }
            else {
                completion(nil, self.formatError())
            }
         
        }
    }
    /**
    预约医生咨询
    
    :param: medicalRecord     病历信息
    :param: sketch            咨询问题概述
    :param: consultWay        咨询方式 1:电话方式;2:面对面方式
    :param: price             咨费
    :param: orderInfo         (可选)是否返回订单信息 0:不返回;1:返回，默认0
    :param: schedule          医生信息
    */
    class func booking(medicalRecord: String,sketch: String,consultWay: String,price: String,orderInfo: String,schedule: String,completion: (NSDictionary?, NSError?) -> Void) {
        requestPOST(kServerAddress + "/api/consult/booking", parameters: paramsToJsonDataParams(["medicalRecord" : medicalRecord,"medicalRecord" : medicalRecord,"sketch" : sketch,"consultWay" : consultWay,"price" : price,"orderInfo" : orderInfo,"schedule" : schedule])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let order = dictionary!["order"] as? NSDictionary {
                    completion(order, nil)
                }
                else {
                    completion(nil, self.formatError())
                }
            }
        }
    }
    /**
    删除病历

    :param: records
    */
    class func medicalRecordDel(records: [String], completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/medicalRecord/del", parameters: paramsToJsonDataParams(["records" : records])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, nil, nil)
        }
    }
    /**
    保存病历
    
    :param: recordId     病历ID（新增时无需填写）
    :param: name         病历所属人姓名
    :param: gender       病历所属人性别（1 男 2 女 3 其他）
    :param: contact      病历所属人联系方式 ）
    :param: anamnesis    病历所属人既往病史
    :param: recordPics   病历所属人病历,图片用英文半角逗号分隔
    */
    class func medicalRecordSave(recordId: String,name: String,gender: String,contact: String,orderInfo: String,anamnesis :String,recordPics: [String],completion: (NSDictionary?, NSError?) -> Void) {
        requestPOST(kServerAddress + "/api/user/medicalRecord/save", parameters: paramsToJsonDataParams(["recordId" : recordId,"name" : name,"gender" : gender,"contact" : contact,"anamnesis" : anamnesis,"recordPics" : recordPics])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let order = dictionary!["order"] as? NSDictionary {
                    completion(order, nil)
                }
                else {
                    completion(nil, self.formatError())
                }
            }
        }
    }
    /**
    获取病历详情
    
    :param: name        病人
    */
    class func getMedicalRecord(name: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/medicalRecord/get", parameters: paramsToJsonDataParams(["name" : name,])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let medicalRecord = dictionary!["medicalRecord"] as? NSDictionary {
                    completion(medicalRecord, nil,nil)
                }
                else {
                    completion(nil, self.formatError(),nil)
                }
            }
        }
    }
    /**
    获取病历本的病历列表
    
    :param: pageNo          分页,若需全部返回，pageSize 传 -1
    :param: pageSize        每页数量
    */
    class func getMedicalRecordList(pageNo: String,pageSize: String, completion: (NSArray?, NSError?, String?) -> Void) {
            requestPOST(kServerAddress + "/api/user/medicalRecord/list", parameters: paramsToJsonDataParams(["pageNo" : pageNo,"pageSize" : pageSize])) { (_, _, _, dictionary, error) -> Void in
                var list = [QN_Case]()
                if dictionary != nil{
                    for caseDictionary in dictionary?["medicalRecords"] as! NSArray {
                        if let dictionary = caseDictionary as? NSDictionary, let tempCase = QN_Case(dictionary) {
                            list.append(tempCase)
                        }
                    }
                    completion(list, nil, nil);
                }
                else {
                    completion(nil, error, dictionary?["errorMsg"] as? String)
                }
            }
        }
    //MARK: 保存病历
    /**
    保存病历
    
    :param: userCase        病例数据模型
    */
    class func saveUserCase(userCase: QN_Case, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/medicalRecord/save", parameters:paramsToJsonDataParams(["name" :userCase.name,"gender" :userCase.gender!,"age" :userCase.age!,"contact" :userCase.contact!,"idCard":userCase.idCard!])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil{
                completion(dictionary, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }

}

// MARK: - 抓取数据
extension QNNetworkTool {
    /// 获取用户最近一次所有体征测量值及评分
    class func fetchAllMonitorData(ownerId: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/apply001", parameters: paramsToJsonDataParams(["ownerId" : ownerId])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let data = dictionary!["data"] as? NSDictionary {
                    completion(data, nil, nil)
                }
                else {
                    completion(nil, self.formatError(), dictionary?["errorMsg"] as? String)
                }
            }
        }
    }
    
    /**
    获取测量数据（最近/历史 数据）不包括计步器（计步器没有ID）
 
    :param: pathType        请求Url类型
    :param: userID          用户标识符(唯一)，与登录时服务器返回的对应
    :param: id              ——查询指定数据时请填写数据的ID （获取最近一次的时候传""）
    :param; startDateTime   最近一段时间开始时间，当查询上一次时传nil
    :param: EndDateTime     最近一段时间结束时间，当查询上一次时传nil
    :param: block           请求完成的回调
    */
    class func fetchCheckData(ownerId: String, id: String, checkType: PhysicalSign, completion: (AnyObject?, NSError?) -> Void){
        requestPOST(kServerAddress + checkType.urlString, parameters: paramsToJsonDataParams(["ownerId" : ownerId, "id":id])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let data = dictionary!["data"] as? NSDictionary {
                    completion(checkType.transformModel(data), nil)
                }
                else {
                    completion(nil, self.formatError())
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    /**
    获取计步器测量数据（最近/历史 数据）
    
    :param: ownerId        用户唯一标识
    :param: launchDateTime 不查询最近的数据，查询指定的天数，请填写此参数(最近传:"") 2015-10-10
    :param: checkType      获取的类型
    :param: completion     请求完成的回调
    */
    class func fetchPedometerData(ownerId: String, launchDateTime: String, checkType: PhysicalSign, completion: (AnyObject?, NSError?) -> Void){
        requestPOST(kServerAddress + checkType.urlString, parameters: paramsToJsonDataParams(["ownerId" : ownerId, "launchDateTime":launchDateTime])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let data = dictionary!["data"] as? NSDictionary {
                    completion(checkType.transformModel(data), nil)
                }
                else {
                    completion(nil, self.formatError())
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    //MARK:  获取用户收缩压周趋势或月趋势
    /**
    *
    *  @param pathType 请求Url类型
    *  @param userID 用户标识符(唯一)，与登录时服务器返回的对应
    *  @param flag   "0" 用户最近7天测量数据 "1" 用户最近30天测量数据
    *  @param block  结果回调
    */
    class func fetchTrendData(ownerId: String, flag: String,checkType: PhysicalSign,completion: (AnyObject?, NSError?) -> Void){
        requestPOST(kServerAddress + checkType.trendUrlString, parameters: paramsToJsonDataParams(["ownerId" : ownerId,"flag":flag])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK:  获取体征分页历史数据
    /**
    *
    *  @param pathType 请求Url类型
    *  @param userID 用户标识符(唯一)，与登录时服务器返回的对应
    *  @param flag   "0" 用户最近7天测量数据 "1" 用户最近30天测量数据
    *  @param block  结果回调
    */
    class func fetchHistoryData(ownerId: String, gId: String,pageIndex: String,pageCount: String,checkType: PhysicalSign,completion: (AnyObject?, NSError?) -> Void){
        requestPOST(kServerAddress + checkType.historyUrlString, parameters: paramsToJsonDataParams(["ownerId":ownerId,"gId":gId,"pageIndex":pageIndex,"pageCount":pageCount])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }

    //MARK: 获取群组所在城市（新建账号所填写的城市）的天气
    /**
    *
    *  @param groupID
    */
    class func fetchWeatherData(groupID: String,completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/api/applyWeather"
        requestPOST(url, parameters:paramsToJsonDataParams(["groupId": groupID])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let data = dictionary!["data"] as? NSDictionary {
                    completion(data, nil)
                }
                else {
                    completion(nil, self.formatError())
                }
            }
            else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: 获取最近一次用户的定位信息
    /**
    :param: gId
    :param: completion
    */
    class func fetchUserLocation(ownerId: String, completion: (AnyObject?, NSError?, String?) -> Void){
        let url = kServerAddress + "/api/apply016"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }
    
    //MARK: 获取GPS历史一段时间内的轨迹
    class func fetchHistroyLoaction(ownerId:String, startDateTime:String, endDateTime:String, completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/monitor/monitorAction!fetchUserLocation.action"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId,"startDateTime":startDateTime,"endDateTime":endDateTime])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 获取医疗建议/单项报告列表
    /**
    :param: ownerId
    :param: pageLastTime
    :param: completion
    */
    class func fetchDoctorAdviceList(ownerId: String,pageLastTime:String , completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/api/applyAdviceReport"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId,"pageLastTime":pageLastTime])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 获取单项报告和医疗建议的详情
    /**
    :param: ownerId    <#ownerId description#>
    :param: reportId   :检测报告的ID 字符类型
    :param: completion
    */
    class func fetchDoctorAdviceDetail(ownerId: String, reportId:String,completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/api/applySignReport"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId,"id":reportId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 获取用户月报列表
    /**
    :param: ownerId
    :param: pageIndex 第几页 int类型
    :param: pageLastTime 向后翻页时最后一条数据的时间, 第一页查询或更新列表，参数传-1,
    :param: pageFirstTime 向前翻页时第一条数据的时间, 第一页查询或更新列表，参数传-1
    :param: completion
    */
    class func fetchUserMonthlyList(ownerId: String , pageLastTime:String , completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/api/applyMonthList"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId,"pageLastTime":pageLastTime])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 获取用户月报详情
    /**
    :param: ownerId
    :param: reportId
    :param: completion
    */
    class func fetchUserMonthlyDetail(ownerId: String, reportId:String,completion: (AnyObject?, NSError?) -> Void){
        let url = kServerAddress + "/api/applyDetailReport"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId": ownerId,"id":reportId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }

    
}

//MARK:- 个人中心
extension QNNetworkTool {
    
    //MARK: 获取我要吐槽列表接口
    /**
    :param: start      分页偏移量
    :param: limit      每页条数
    :param: completion
    */
    class func fetchAloundAppList(start: String , limit:String , completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress + "/api/im/feedback/pull"
        requestPOST(url, parameters:["start": start,"limit":limit]) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 发表我要吐槽发表接口
    class func postAloundAppContent(content: String , completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress +  "/api/im/feedback/post"
        requestPOST(url, parameters:["content": content]) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    
    /**
    //MARK: 手表 -- 请求更改手表绑定的sos号码
    
    :param: ownerId     用户ID
    :param: sosPhone    SOS号码，关联手表的sos请求键对应的号码
    :param: phone1      号码1，可以为空
    :param: phone2      号码2，可以为空
    :param: phone3      号码3，可以为空
    :param: listenPhone 监听号码，可以为空
    */
    class func changeWatcherSOSPhoneNumber(ownerId: String, sosPhone: String, phone1: String?, phone2: String?, completion: (NSDictionary?, NSError?) -> Void) {
        var params = [String: String]()
        params["ownerId"] = ownerId
        params["sosNum1"] = sosPhone
        params["sosNum2"] = phone1 ?? ""
        params["sosNum3"] = phone2 ?? ""
        
        let url = kServerAddress + "/api/watch/telChange"
        requestPOST(url, parameters: paramsToJsonDataParams(params)) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 手表 -- 获取手表sos号码绑定状态或当前已绑定的sos号码
    /**
    :param: ownerId      用户ID
    :param:  sosNum1 -- sos号码1，关联手表的sos请求键对应的号码
    sosNum2 -- 可选，默认为空串
    sosNum3 -- 可选，默认为空串
    sosNum4 -- 可选，默认为空串
    listenNum1 -- 可选，默认为空串
    state  -- -1（号码绑定过期）/ 0 绑定中 / 1 绑定完成
    */
    class func fetchWatcherSOSPhoneNumber(ownerId:String, completion:(NSDictionary?, NSError?) -> Void) {
        let url = kServerAddress +  "/api/watch/telState"
        requestPOST(url, parameters:paramsToJsonDataParams(["ownerId":ownerId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
    //MARK: 修改用户头像
    /**
    :param: file     头像二进制文件
    :param: fileName 头像名字
    */
    class func updateUserFace(photo: String, completion: (succeed : Bool, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/photo", parameters: paramsToJsonDataParams(["photo" : photo])) { (_, _, _, dictionary, error) -> Void in
            let succeed: Bool
            if dictionary != nil {
                if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 1000 {
                    succeed = true
                }
                else {
                    succeed = false
                }
                completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
            }else {
                succeed = false
                completion(succeed: succeed, error, nil)
            }
        }
        
    }
    //
    //MARK: 修改用户头像
    /**
    :param: file     头像二进制文件
    :param: fileName 头像名字
    */
    class func uploadUserPhoto(file: NSData, fileName: NSString, completion: (NSDictionary?, NSError?) -> Void) {
        let url = NSURL(string: kServerAddress+"/api/user/photo")
        request(self.productUploadRequest(url, method: "POST", data: file, fileName: fileName)).response {
            do {
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData($2!, options: NSJSONReadingOptions.MutableContainers)
                let dictionary = jsonObject as? NSDictionary
                completion(dictionary, $3)
            } catch {
               //TODO:
            }
           
        }
    }
    //MARK: 修改设备昵称
    class func updateDeviceName(nickName:String, completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress +  "/api/im/client/updateNick"
        requestPOST(url, parameters: ["nick":nickName]) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    //MARK: 修改家庭群组成员头像
    class func updateGroupPhoto(photo:String,userId : String, completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress +  "/api/user/updateGroupUserPhoto"
        requestPOST(url, parameters: paramsToJsonDataParams(["photo":photo,"userId":userId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    //MARK: 修改用户昵称
    class func updateNickName(nickName:String, completion:(NSDictionary?, NSError?) -> Void){
        requestPOST(kServerAddress + "/api/user/nickName", parameters: paramsToJsonDataParams(["nickName":nickName])) { (_, _, _, dictionary, error) -> Void in
              completion(dictionary, error)
        }
    }
    
    //MARK: 获取已绑定家庭号用户的服务
    class func fetchUserServe(completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress +  "/api/user/serve"
        requestPOST(url, parameters: nil) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 1000 {
                if let data = dictionary!["data"] as? NSDictionary  {
                   completion(data, error)
                }
                
            }
        }
    }
    //MARK: 修改密码
    /**
    *
    *  @param groupID
    *  @param pageNo
    */
    class func changePassWord(old: String, new: String,type:String,completion:(NSDictionary?, NSError?) -> Void){
        let url = kServerAddress + "/api/sys/modPwd"
        requestPOST(url, parameters:["oldPwd": old, "pwd": new,"type":type]) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
        
    }
}

//MARK:- 系统消息相关
extension QNNetworkTool {
    /**
    更新家庭消息和系统消息未读总数
    
    :param: gId 用户唯一识别
    */
    class func updateMyMessageNotReadCount(gId: String = g_currentGroup!.gId ?? "") {
        requestPOST(kServerAddress + "/api/message/mymsg/unreadcount", parameters: paramsToJsonDataParams(["gId" : gId])) { (_, _, _, dictionary, error) -> Void in
            if let noReadCount = (dictionary?["unreadCount"])?.integerValue where g_NotReadMyMessageCount != noReadCount {
                g_NotReadMyMessageCount = noReadCount
            }
        }
    }
    
    /**
    抓取系统消息
    
    :param: ownerId   用户唯一识别
    :param: pageIndex 第几页
    :param: pageCount 每页显示数量
    */
    class func fetchSystemMessage(gId: String, pageNo: Int, completion: (QN_SystemMessageList?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/message/sysmsg/list", parameters: paramsToJsonDataParams(["gId" : gId, "pageNo" : pageNo])) { (_, _, _, dictionary, error) -> Void in
                if dictionary != nil, let messageList = QN_SystemMessageList(dictionary!) {
                    completion(messageList, nil, nil);
                }
                else {
                    completion(nil, error, dictionary?["errorMsg"] as? String)
                }
        }
    }
    
    
}

//MARK:- 我的消息相关
extension QNNetworkTool {
    
    /**
    上报registration_id和token
    
    :param: registrationId
    :param: token
    */
    class func uploadRegistrationIdAndToken(registrationId: String = APService.registrationID(), token: String? = g_deviceToken) {
        if !g_isLogin { return } // 此接口必须登录
        if (registrationId).characters.count == 0 { return }  // 此接口必须登录极光
        
        var params = [String : String]()
        params["rid"] = registrationId
        params["token"] = token
        requestPOST(kServerAddress + "/api/im/message/report", parameters: params) { (_, _, _, dictionary, error) -> Void in
        }
        // 上传别名
        if g_currentLoginID == nil {
           APService.setAlias(g_currentGroup!.gId, callbackSelector: nil, object: nil)
        }else{
           APService.setAlias("user_"+g_currentLoginID!, callbackSelector: nil, object: nil)
        }
        // 更新系统未读通知数
        self.updateMyMessageNotReadCount()
        self.updateApplyNotReadCount()
    }
    /**
    发送消息
    
    :param: content    发送消息的内容
    :param: completion 发送完成的回调
    */
    class func sendMessage(content: String, completion: (QN_Message?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/im/message/post", parameters: ["content" : content]) { (_, _, _, dictionary, error) -> Void in
            var message: QN_Message? = nil
            if let messageDictionary = dictionary?["data"] as? NSDictionary {
                message = QN_Message(messageDictionary)
            }
            completion(message, error, dictionary?["errorMsg"] as? String)
        }
    }
    
    /**
    获取消息列表
    
    :param: lastDataId   请求该消息之前的消息
    :param: lastDataTime 请求该时间之前的消息
    :param: completion   请求完成的回调
    */
    class func fetchMessage(lastDataId: String? = nil, lastDataTime: String? = nil, completion: (QN_MessageList?, NSError?, NSDictionary?) -> Void) {
        var params = [String : String]()
        params["id"] = lastDataId
        params["time"] = lastDataTime
        requestPOST(kServerAddress + "/api/im/message/pull", parameters: params) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let data = dictionary!["data"] as? NSDictionary {
                if let messageList = QN_MessageList(data) {
                    completion(messageList, nil, nil); return
                }
            }
            completion(nil, error, dictionary)
        }
    }
    
    /**
    084、我的消息
    
    :param: gId     用户组Id
    */
    class func fetchMyMessage(gId: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/message/mymsg/push", parameters: paramsToJsonDataParams(["gId" : gId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }
   
    /**
    085、将检测提醒设置为已读
    
    :param: ownerId  用户ID
    :param: reportId 报告ID
    :param: readType 更新读取的类型 1:医疗建议 2：月报
    */
    class func updateCheckMessageIsRead(gId: String = g_currentGroup?.gId ?? "", type: String = "1") {
        requestPOST(kServerAddress + "/api/message/checkmsg/read", parameters: paramsToJsonDataParams(["gId" : gId, "type" : type])) { (_, _, _, dictionary, error) -> Void in
        }
    }
    
    /**
    085、将返现提醒设置为已读
    
    :param: gId <#gId description#>
    */
    class func updateTaskMessageIsRead(gId: String = g_currentGroup?.gId ?? "") {
        self.updateCheckMessageIsRead(gId, type: "2")
    }
}

//MARK:- 医疗建议和月报消息相关
extension QNNetworkTool {
    /**
    更新月报和医疗报告未读数量
    
    :param: ownerId 用户唯一识别
    */
    class func updateApplyNotReadCount(ownerId: String = g_currentUserInfo?.id ?? "") {
        requestPOST(kServerAddress + "/api/applyNoReadCount", parameters: paramsToJsonDataParams(["ownerId" : ownerId])) { (_, _, _, dictionary, error) -> Void in
            if let noReadCount = (dictionary?["data"]?["reportNumber"])?.integerValue where g_NotReadMonthlyReportCount != noReadCount {
                g_NotReadMonthlyReportCount = noReadCount
            }
            if let noReadCount = (dictionary?["data"]?["suggestNumber"])?.integerValue where g_NotReadSuggestCount != noReadCount {
                g_NotReadSuggestCount = noReadCount
            }
        }
    }
    /**
    获取月报和医疗报告未读数量
    
    :param: ownerId 用户唯一识别
    */
    class func fetchApplyNotReadCount(ownerId: String,completion: (Int) -> Void) {
        requestPOST(kServerAddress + "/api/applyNoReadCount", parameters: paramsToJsonDataParams(["ownerId" : ownerId])) { (_, _, _, dictionary, error) -> Void in
            var count = 0
            if let noReadCount = (dictionary?["data"]?["reportNumber"])?.integerValue  {
                count += noReadCount
            }
            if let noReadCount = (dictionary?["data"]?["suggestNumber"])?.integerValue {
                count += noReadCount
            }
            completion(count)
        }
    }
    /**
    更新月报或医疗建议信息为已读
    
    :param: ownerId  用户ID
    :param: reportId 报告ID
    :param: readType 更新读取的类型 1:医疗建议 2：月报 
    */
    class func updateSuggestAndMonthIsRead(ownerId:String, reportId:String, readType:String){
        requestPOST(kServerAddress + "/api/applyReadMsg", parameters: paramsToJsonDataParams(["ownerId" : ownerId,"reportId":reportId,"readType":readType])) { (_, _, _, dictionary, error) -> Void in
        }
    }
}
//MARK:- 预约咨询相关接口（我的医生、找医生、预约）
extension QNNetworkTool {
    //MARK:- 社区版:获取家庭医生
    class func fetchMyDoctor(completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/community/familyDoctor", parameters: nil) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }
    //MARK:- 获取我预约的医生(备注：分页数据)
    class func fetchMyAttentionDoctors(start:String, limit: String, completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/community/bookedDoctorList", parameters: paramsToJsonDataParams(["pageNo" : start,"pageSize":limit])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                var list = [QN_Doctor]()
                for dict in dictionary?["list"] as! NSArray {
                    if let tempDict = dict as? NSDictionary, let doctor = QN_Doctor(tempDict) {
                        list.append(doctor)
                    }
                }
                completion(list, nil, nil)
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }

        }
    }
    //MARK:- 获取医生主页信息
    /**
    获取医生主页信息
    
    :param: doctorId  医生ID
    :param: loginId   注册返回ID
    */
    class func fetchDoctorInfo(doctorId:String, loginId: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/info", parameters: paramsToJsonDataParams(["doctorId" : doctorId,"loginId":loginId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }
    //MARK:- 获取咨询医生列表(备注：分页数据)
    /**
    获取咨询医生列表
    
    :param: name  姓名
    :param: provinceId   注省份ID
    :param: cityId      城市ID
    :param: areaId   区ID
    :param: illId   擅长的疾病ID
    :param: start   分页起始
    :param: limit   每页条数，默认15
    */
    class func fetchDoctorsList(name : String,provinceId : String,cityId : String,illId : String,pageNo:String, pageSize: String, completion: (NSArray?, NSError?, String?) -> Void) {
        //如果没有相应条件，不要传空数据
        var params : [String : AnyObject]!
        if (name != "") {
            //姓名筛选
            params = paramsToJsonDataParams(["name" : name,"pageNo" : pageNo,"pageSize":pageSize])
        }else if(cityId == "" && illId == "") {
            params = paramsToJsonDataParams(["pageNo" : pageNo,"pageSize":pageSize])
        }else if cityId == ""  {
            params = paramsToJsonDataParams(["pageNo" : pageNo,"pageSize":pageSize,"illId":illId])
        }else if illId == ""  {
            params = paramsToJsonDataParams(["pageNo" : pageNo,"pageSize":pageSize,"cityId":cityId])
        }else {
            //智能，地区，病症筛
            params = paramsToJsonDataParams(["cityId" :cityId ,"illId" : illId,"pageNo" : pageNo,"pageSize":pageSize])
        }
        requestPOST(kServerAddress + "/api/doctor/pull", parameters: params) { (_, _, _, dictionary, error) -> Void in
            var list = [QN_Doctor]()
            if dictionary != nil{
                for caseDictionary in dictionary?["list"] as! NSArray {
                    if let dictionary = caseDictionary as? NSDictionary, let tempDoctor = QN_Doctor(dictionary) {
                        list.append(tempDoctor)
                    }
                }
                completion(list, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }
    //MARK:- 医生预约日程表
    /**
    医生预约日程表
    
    :param: doctorId  医生ID
    :param: flag   时间标示（1:本周，2:下周）
    */
    class func fetchDoctorSchedule(doctorId:String, flag: String, completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/community/schedule", parameters: paramsToJsonDataParams(["doctorId" : doctorId,"flag":flag])) { (_, _, _, dictionary, error) -> Void in
            var list = [QN_ScheduleList]()
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                for caseDictionary in dictionary?["data"] as! NSArray {
                    if let dictionary = caseDictionary as? NSDictionary, let tempDoctor = QN_ScheduleList(dictionary) {
                        list.append(tempDoctor)
                    }
                }
                completion(list, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }

        }
    }

   
    //MARK:- 获取预约订单进度(备注：分页数据)
    /**
    :param: pageNo
    :param: pageSize
    */
    class func fetchOrderMessage(pageNo: String,pageSize: String, completion: (NSArray?, NSError?, String?) -> Void) {
        let params = paramsToJsonDataParams(["pageNo":pageNo,"pageSize" : pageSize])
        requestPOST(kServerAddress + "/api/order/message/pull", parameters: params) { (_, _, _, dictionary, error) -> Void in
            var list = [QN_OrderProgress]()
            if dictionary != nil{
                for orderDictionary in dictionary?["messages"] as! NSArray {
                    if let dictionary = orderDictionary as? NSDictionary {
                        let tempOrder = QN_OrderProgress(dictionary)
                        list.append(tempOrder)
                    }
                }
                completion(list, nil, nil);
            } else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
            
        }
    }
    //MARK:- 用户添加或取消关注医生
    /**
    用户添加或取消关注医生
    
    :param: doctorId  医生ID
    :param: loginId   注册返回ID
    */
    class func refollowedDoctor(doctorId:String, loginId: String, followed: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/doctor/refollowed", parameters: paramsToJsonDataParams(["doctorId" : doctorId,"loginId":loginId,"followed":followed])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }
    //MARK:- 更改家庭医生
    /**
   更改家庭医生
    
    :param: proxyId   显示在客户端的、医生给客户添加用的id
    */
    class func addFamilyDoctor(proxyId:String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/user/familydoctor", parameters: paramsToJsonDataParams(["proxyId" : proxyId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error, dictionary?["errorMsg"] as? String)
        }
    }

    //MARK:- 获得咨询完成后用户对医生的评价
    /**
    获得咨询完成后用户对医生的评价
    
    :param: doctorId  医生ID
    :param: pageNo   页码 从1开始
    :param: pageSize   每页记录数
    */
    class func commentDoctor(doctorId:String, pageNo: String,pageSize: String, completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/comment", parameters: paramsToJsonDataParams(["doctorId" : doctorId,"pageNo":pageNo,"pageSize":pageSize])) { (_, _, _, dictionary, error) -> Void in
            var list = [QN_DoctorComment]()
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                for caseDictionary in dictionary?["commentDataList"] as! NSArray {
                    if let dictionary = caseDictionary as? NSDictionary, let tempDoctor = QN_DoctorComment(dictionary) {
                        list.append(tempDoctor)
                    }
                }
                completion(list, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
            
        }
    }
    //MARK: 上传图片(病历 、医生头像、 医生其他资料、用户头像)
    /**
    :param: img     图片二进制文件
    :param: fileName 图片名字
    :param: type   图片类型
    */
    class func uploadDoctorImage(file: NSData, fileName: NSString,type: NSString, completion: (NSDictionary?, NSError?) -> Void) {
        let url = NSURL(string: kServerAddress+"/api/upload/image")
        request(self.uploadRequest(url, method: "POST", data: file, fileName: fileName,type:type)).response {
            do {
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData($2!, options: NSJSONReadingOptions.MutableContainers)
                let dictionary = jsonObject as? NSDictionary
                completion(dictionary, $3)
            }catch {
                
            }
           
        }
    }
    //MARK: 预约医生咨询
    /**
    :param: dictionary     图片二进制文件
    */
    class func bookDoctor(dictionary: NSDictionary, completion: (NSDictionary?, NSError?, String?) -> Void) {
        do {
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions())
            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            let para = ["jsonData" : jsonDataString]
            requestPOST(kServerAddress + "/api/consult/booking", parameters: para) { (_, _, _, dictionary, error) -> Void in
                if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 1000{
                    completion(dictionary, nil, nil);
                }
                else {
                    completion(nil, error, dictionary?["errorMsg"] as? String)
                }
                
            }
        }
      
    }
    //MARK: 统计预约进度消息未读数

    class func fetchMessageCount(completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/order/message/count", parameters:nil) { (_, _, _, dictionary, error) -> Void in
            let list = [QN_DoctorComment]()
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 1000{
                completion(list, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
            
        }
    }
   
    //MARK: 获取社区设置(科室列表，站点列表)
    
    class func communityConfig(completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/community/config", parameters:nil ) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0{
                completion(dictionary, nil, nil);
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
            
        }
    }
    //MARK: 获取社区医生列表
    /**
    :param: name                医生名
    :param: departmentId        社区ID
    :param: siteId              站点名称
    :param: pageNo              页码
    :param: pageSize            每页数量
    */
    class func fetchDoctorList(name : String,departmentId : String,siteId : String,pageNo : String,pageSize : String,completion: (NSArray?,Int?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/community/doctorList", parameters:paramsToJsonDataParams(["departmentId" : departmentId,"pageNo" : pageNo,"pageSize" : pageSize]) ) { (_, _, _, dictionary, error) -> Void in
            var list = [QN_Doctor]()
            if dictionary != nil{
                for caseDictionary in dictionary?["list"] as! NSArray {
                    if let dictionary = caseDictionary as? NSDictionary, let tempDoctor = QN_Doctor(dictionary) {
                        list.append(tempDoctor)
                    }
                }
                if  let count = dictionary?["count"] as? Int {
                    completion(list,count, nil, nil);
                } else {
                    completion(list,nil, nil, nil);
                }
            }
            else {
                completion(nil,nil, error, nil)
            }
        }
    }
}





