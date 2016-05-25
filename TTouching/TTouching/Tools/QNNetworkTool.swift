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
//                QNNetworkTool.uploadRegistrationIdAndToken()
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
////                        let vc = (BindingIDViewController.CreateFromStoryboard("Login") as? BindingIDViewController)!
//                        vc.flag = true
//                        vc.finished = { () -> Void in
//                            QNNetworkTool.login(GroupId: groupId, GroupPassword: groupPassword)
//                        }
//                        viewController.presentViewController(UINavigationController(rootViewController: vc), animated: true, completion: nil)
//
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
//                    QNNetworkTool.uploadRegistrationIdAndToken()
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






