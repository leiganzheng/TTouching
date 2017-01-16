//
//  QNNetworkTool.swift
//  QooccHealth
//
//  Created by Leiganzheng on 15/4/8.
//  Copyright (c) 2015年 Leiganzheng. All rights reserved.
//

import UIKit
import Alamofire

// MARK: - 服务器地址
private let (kServerAddress) = { () -> (String) in
    // 正式环境
    ("http://www.reluxe.com.tw/phpok45/api.php")
}()

/**
*  //MARK:- 网络处理中心
*/


class QNNetworkTool: NSObject{
    
}

/**
*  //MARK:- 网络基础处理
*/
private extension QNNetworkTool{
    
    /**
    //MARK: 生产共有的 URLRequest，如果是到巨细的服务器请求数据，必须使用此方法创建URLRequest
        
    :param: url    请求的地址
    :param: method 请求的方式， Get Post Put ...
    */
    private class func productRequest(url: NSURL!, method: NSString!) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
////        request.addValue(g_doctor?.auth ?? "", forHTTPHeaderField: "AUTH") // 用户身份串,在调用/api/login 成功后会返回这个串;未登录时为空
//        request.addValue("1", forHTTPHeaderField: "AID")                // app_id, iphone=1, android=2
//        request.addValue(APP_VERSION, forHTTPHeaderField: "VER")        // 客户端版本号
//        request.addValue(g_UDID, forHTTPHeaderField: "CID")             // 客户端设备号
        request.HTTPMethod = method as String
        return request
    }
    
    //MARK: 后台返回的数据错误，格式不正确 的 NSError
    private class func formatError() -> NSError {
        return NSError(domain: "后台返回的数据错误，格式不正确", code: 10087, userInfo: nil)
    }
    
    /**
    //MARK: Request 请求通用简化版
    
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
                    
                    let errorCode = Int((dictionary!["status"] as! String))
                    if errorCode == 1000 || errorCode == 1 {
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
    //MARK: Get请求通用简化版
    
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
    //MARK: Post请求通用简化版
    
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
    //MARK: 将输入参数转换成字符传
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
    
    private class func toJsonDataParams(params: [String : AnyObject]) -> String {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions())
            let jsonDataString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            
            return jsonDataString
        }catch{
            return ""
        }
    }

}

//MARK:- 登录 & 登出 & 注册会员 & 检查账号重复
extension QNNetworkTool {
    /**
    登录接口
    
    :param: Id       登录Id
    :param: Password 登录密码
    :param: completion    请求完成后的回掉
    */
    class func login(User user: String, Password password: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress, parameters: ["user" : user, "pass" : password,"c":"login"]) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let dic = dictionary?["content"] as? NSDictionary {
                // 登录成功，保存账号密码到本地
//                saveAccountAndPassword(id, password: password)
//                g_doctor = doctor

                let asyncLogin = { () -> Void in
                    
                }
//                var asyncLoginCount = 0
//                               completion(doctor, nil, nil)
            }
            else {
//                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }
    
    /**
    退出登录，并且拥有页面跳转功能
    */
    class func logout() {
        requestPOST(kServerAddress, parameters: ["c":"logout"]) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let dic = dictionary?["content"] as? NSDictionary {
                
                let asyncLogin = { () -> Void in
                    
                }
                         }
            else {
            }
        }

        //        cleanPassword()
        //激光推送设置空字符串 （@""）表示取消之前的设置。
        QNTool.enterLoginViewController()
    }
    
    /**
     注册会员
     */
    class func regishter(phone: String, user: String, password: String, chpassword: String, completion: (succeed: Bool, NSError?, String?) -> Void){
        requestPOST(kServerAddress, parameters: ["c":"register","f":"save","group_id":"7","mobile":phone,"user":user,"newpass":password,"chkpass":chpassword]) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let dic = dictionary?["content"] as? NSDictionary {
                
                let asyncLogin = { () -> Void in
                    
                }
                
            }
            else {
            }
        }
        
    }
    /**
     检测帐号重复
     */
    class func checkUser(user: String, completion: (succeed: Bool, NSError?, String?) -> Void){
        requestPOST(kServerAddress, parameters: ["c":"register","f":"check_user","user":user]) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil, let dic = dictionary?["content"] as? NSDictionary {
                
                let asyncLogin = { () -> Void in
                    
                }
                
            }
            else {
            }
        }
        
    }
}


/*
 
 1.1	登录会员
	说明：	登录已注册帐号和密码
	数据交换格式	JSON
	请求	POST
	地址	http://www.reluxe.com.tw/phpok45/api.php
 
	请求字段说明：
	字段	必需	类型及范围
	c	是	login
	user	是	帐号，默认以手机号
	pass	是	密码
 
	示例
	http://www.reluxe.com.tw/phpok45/api.php?c=login&user=jacky&pass=123456
 
	返回结果
	status		1:ok    2:error
	content		内容说明
 
	json解析		http://json.cn/
 
 
 1.2	登出会员
	说明：	退出已登录帐号和密码
	数据交换格式	JSON
	请求	POST
	地址	http://www.reluxe.com.tw/phpok45/api.php
 
	请求字段说明：
	字段	必需	类型及范围
	c	是	logout
 
	示例
	http://www.reluxe.com.tw/phpok45/api.php?c=login&user=jacky&pass=123456
 
	返回结果
	status		1:ok    2:error
	content		内容说明
 
 
 1.3	注册会员
	说明：	填写手机，帐号，密码，邮箱
	数据交换格式	JSON
	请求	POST
	地址	http://www.reluxe.com.tw/phpok45/api.php
 
	请求字段说明：
	字段	必需	类型及范围
	c	是	register
	f	是	save
	group_id	是	会员组，id=7手机会员（免审核）
	mobile	是	手机号
	user	是	帐号
	newpass	是	密码
	chkpass	是	确认密码
	email	是	邮箱
 
	示例
	http://www.reluxe.com.tw/phpok45/api.php?c=register&f=save&group_id=7&mobile=13711688482&user=jacky1&newpass=123456&chkpass=123456&email=vitowu@sohu.com
 
	返回结果
	status		1:ok    2:error
	content		内容说明
 
 1.4	检测帐号重复
	说明：	检测注册帐号是否重复
	数据交换格式	JSON
	请求	POST
	地址	http://www.reluxe.com.tw/phpok45/api.php
 
	请求字段说明：
	字段	必需	类型及范围
	c	是	register
	f	是	check_user
	user	是	帐号
 
	示例
	http://www.reluxe.com.tw/phpok45/api.php?c=register&f=check_user&user=jacky
 
 
 */











