//
//  QNNetworkTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/8.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import UIKit
import Alamofire
import CocoaAsyncSocket

// MARK: - 医生服务器地址, 体征数据服务器地址
private let (kServerAddress, kXiTeServerAddress) = { () -> (String, String) in
    // 正式环境
    ("http://xite.qoocc.com/doctor", "http://xite.qoocc.com/dc")
    // 测试环境
//    ("http://test.xite.qoocc.com/doctor", "http://test.xite.qoocc.com/dc")
}()

/**
*  //MARK:- 网络处理中心
*/
let addr = "192.168.0.10"
let port:UInt16 = 33632

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
//        request.addValue(g_doctor?.auth ?? "", forHTTPHeaderField: "AUTH") // 用户身份串,在调用/api/login 成功后会返回这个串;未登录时为空
        request.addValue("1", forHTTPHeaderField: "AID")                // app_id, iphone=1, android=2
        request.addValue(APP_VERSION, forHTTPHeaderField: "VER")        // 客户端版本号
        request.addValue(g_UDID, forHTTPHeaderField: "CID")             // 客户端设备号
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

//MARK:- 用户中心(上传)
extension QNNetworkTool {
    /**
    //MARK: 生产一个用于上传的Request
    
    :param: url      上传的接口的地址
    :param: method   上传的方式， Get Post Put ...
    :param: data     需要被上传的数据
    :param: fileName 上传的文件名
    */
    //构建上传request
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

    //MARK: 上传图片(病历 、医生头像、 医生其他资料、用户头像)
    /**
    :param: img         图片二进制文件
    :param: fileName    图片名字
    :param: type        图片类型  可选值：medicalRecord 病历;doctorFace 医生头像; doctorImg 医生其他图片;clientImg 用户头像;
    */
    class func uploadDoctorImage(file: NSData, fileName: NSString,type: NSString, completion: (NSDictionary?, NSError?) -> Void) {
        let url = NSURL(string: kXiTeServerAddress+"/api/upload/image")
        request(self.uploadRequest(url, method: "POST", data: file, fileName: fileName,type:type)).response {
            do {
                let jsonObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData($2!, options: NSJSONReadingOptions.MutableContainers)
                let dictionary = jsonObject as? NSDictionary
                completion(dictionary, $3)
  
            }catch{
                
            }
            
        }
    }

    /**
    保存医生个人简介
    
    :param: doctor_id       登录Id
    :param: introduce       登录密码
    :param: completion      请求完成后的回掉
    */
    class func saveDocIntroduce(doctor_id : String, introduce: String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/register/docUpdateAction!saveIntroduce.action", parameters: paramsToJsonDataParams(["doctor_id" : doctor_id, "introduce" : introduce])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
              completion(dictionary,nil,nil)
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }

       /**
    修改医生头像或密码（应该是名字）
    
    :param: columanName       要修改头像传  head_pic ; 要修改姓名传 doct_name;
    :param: columnValue      要保存的值（如果保存的是头像，则先调用上传图片接口，放入返回的文件名）
    */
    class func doctorRecolumn(columnName : String,columnValue : String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/recolumn", parameters: paramsToJsonDataParams(["columnName" : columnName,"columnValue" : columnValue])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                completion(dictionary,nil,nil)
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }
   
    /**
    修改医生头像或密码（应该是名字）
    
    :param: doctor_id       
    :param: good_describe   描述的内容长度不超过500个字节
    :param: illness_id      病症的ID组成的字符串
    */
    class func saveGoodDescribe(doctor_id : String,good_describe : String,illness_id : String, completion: (NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/register/docUpdateAction!saveGoodDescribe.action", parameters: paramsToJsonDataParams(["doctor_id" : doctor_id,"good_describe" : good_describe,"illness_id" : illness_id])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                completion(dictionary,nil,nil)
            }
            else {
                completion(nil, error, dictionary?["errorMsg"] as? String)
            }
        }
    }
    /**
    保存医生资格认证信息
    
    :param: doctor_id
    :param: good_describe   描述的内容长度不超过500个字节
    :param: illness_id      病症的ID组成的字符串
    */
    class func saveCredential(doctor_id : String,work_card : String,identity : String,head_pic : String, completion: (succeed : Bool?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/register/docUpdateAction!saveCredential.action", parameters: paramsToJsonDataParams(["doctor_id" : doctor_id,"work_card" : work_card,"identity" : identity,"head_pic" : head_pic])) { (_, _, _, dictionary, error) -> Void in
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
                completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
            }
        }
    }

}

//MARK:- 登录 & 登出
extension QNNetworkTool {
    /**
    登录接口
    
    :param: Id       登录Id
    :param: Password 登录密码
    :param: completion    请求完成后的回掉
    */
//    class func login(Id id: String, Password password: String, completion: (QD_Doctor?, NSError?, String?) -> Void) {
//        requestPOST(kServerAddress + "/api/login", parameters: paramsToJsonDataParams(["account" : id, "password" : password])) { (_, _, _, dictionary, error) -> Void in
//            if dictionary != nil, let doctorDic = dictionary?["data"] as? NSDictionary, let doctor = QD_Doctor(doctorDic) {
//                // 登录成功，保存账号密码到本地
//                saveAccountAndPassword(id, password: password)
//                g_doctor = doctor
//
//                let asyncLogin = { () -> Void in
//                    
//                }
//                var asyncLoginCount = 0
//                               completion(doctor, nil, nil)
//            }
//            else {
//                completion(nil, error, dictionary?["errorMsg"] as? String)
//            }
//        }
//    }
//    class func loginOther(Id id: String, Password password: String, completion: (QD_Doctor?, NSError?, String?) -> Void) {
//        requestPOST(kServerAddress + "/api/login", parameters: paramsToJsonDataParams(["account" : id, "password" : password])) { (_, _, _, dictionary, error) -> Void in
//            if dictionary != nil, let doctorDic = dictionary?["data"] as? NSDictionary, let doctor = QD_Doctor(doctorDic) {
//                // 登录成功，保存账号密码到本地
//                saveAccountAndPassword(id, password: password)
//                g_doctor = doctor
//                completion(doctor, nil, nil)
//            }
//            else {
//                completion(nil, error, dictionary?["errorMsg"] as? String)
//            }
//        }
//    }

    
    /**
    退出登录，并且拥有页面跳转功能
    */
    class func logout() {
        cleanPassword()
        //激光推送设置空字符串 （@""）表示取消之前的设置。
        QNTool.enterLoginViewController()
    }
    
    /**
    重置密码
    
    :param: phone       手机号
    :param: authcode    验证码
    :param: Password    新密码
    :param: completion  请求完成后的回掉
    */
    class func resetPassword(phone: String, authcode: String, password: String, completion: (succeed: Bool, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/register/registerAction!findDoctorPassword.action", parameters: paramsToJsonDataParams(["phone" : phone, "authcode" : authcode,"password" : password])) { (_, _, _, dictionary, error) -> Void in
            let succeed: Bool
            if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 0 {
                succeed = true
            }
            else {
                succeed = false
            }
            completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
        }
    }
    
    /**
    修改密码
    
    :param: doctorId    医生Id
    :param: oldPassword 旧密码
    :param: newPassword 新密码
    :param: completion  请求完成的回调
    */
    class func changePassword(doctorId: String, oldPassword: String, newPassword: String, completion: (succeed: Bool, NSError?, String?) -> Void) {
        var params = [String : String]()
        params["doctorId"] = doctorId
        params["oldPass"] = oldPassword
        params["newPass"] = newPassword
        requestPOST(kServerAddress + "/api/register/registerAction!updateDoctorPassword.action", parameters: paramsToJsonDataParams(params)) { (_, _, _, dictionary, error) -> Void in
            let succeed: Bool
            if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 0 {
                succeed = true
            }
            else {
                succeed = false
            }
            completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
        }
    }
}

// MARK: - 用户信息
extension QNNetworkTool {

    
    /**
    获取管理用户记录数列表
    
    :param: doctorId   医生Id
    :param: completion 请求完成的回调
    */
    class func fetchUserManger(doctorId: String, completion: (NSDictionary?, NSError?) -> Void) {
        requestPOST(kServerAddress + "/api/user/fetchUserAction!doctorAdminUserCount.action", parameters: paramsToJsonDataParams(["doctorId" : doctorId])) { (_, _, _, dictionary, error) -> Void in
            completion(dictionary, error)
        }
    }
    
}

// MARK: - 用户注册相关接口 & 验证码
extension QNNetworkTool {
    /**
    获取验证码
    
    :param: phoneNum   手机号码
    :param: hasRegistor  true：注册时候用，  false： 忘记密码时候用
    :param: completion 完成的回调（内涵验证码）
    */
    class func fetchAuthCode(phoneNum: String, isRegister: Bool, completion: (succeed: Bool, NSError?, String?) -> Void) {
        var params = [String : String]()
        params["phoneNum"] = phoneNum
        params["isRegister"] = isRegister ? "NO" : "YES"
        requestPOST(kServerAddress + "/api/register/registerAction!reqRegisterCode.action", parameters: paramsToJsonDataParams(params)) { (_, _, _, dictionary, error) -> Void in
            let succeed: Bool
            if let errorCode = dictionary?["errorCode"]?.integerValue where errorCode == 0 {
                succeed = true
            }
            else {
                succeed = false
            }
            completion(succeed: succeed, error, dictionary?["errorMsg"] as? String)
        }
    }
    
 
    
   }





// MARK: - 预约地点相关
extension QNNetworkTool {
    //   预约地点列表
    /**
    *   预约地点列表
    *  @param pageNo      页码，正数
    *  @param pageSize    每页显示数量，正数
    *  @param completion  结果回调
    */
    class func fetchConsultAddressList(pageNo: String,pageSize : String = "10", completion: (NSArray?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/consultAddress/list", parameters: paramsToJsonDataParams(["pageNo" : pageNo,"pageSize" : pageSize])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    let addresses = dictionary!["addresses"] as! NSArray
                    completion(addresses, nil, nil);
                } else {
                    completion(nil, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(nil, error, nil)
            }
        }
    }
    //   新建/更新保存预约地点
    /**
    *   新建/更新保存预约地点
    *  @param id            预约地点记录ID，在更新的时候需要传，新建的时候不需要或传0
    *  @param address       地址，限制50个字
    *  @param completion  结果回调
    */
    class func saveConsultAddress(id: String = "0",address : String, completion: (succeed : Bool!, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/consultAddress/save", parameters: paramsToJsonDataParams(["id": id,"address" : address])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    completion(succeed: true, nil, nil);
                } else {
                    completion(succeed: false, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(succeed: false, error, nil)
            }
        }
    }
    //   设置常用预约地点
    /**
    *   设置常用预约地点
    *  @param id            预约地点记录ID，在更新的时候需要传，新建的时候不需要或传0
    *  @param completion  结果回调
    */
    class func setCommonUsed(id: String = "0", completion: (succeed : Bool!, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/consultAddress/setCommonUsed", parameters: paramsToJsonDataParams(["id" : id])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    completion(succeed: true, nil, nil);
                } else {
                    completion(succeed: false, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(succeed: false, error, nil)
            }
        }
    }
    //   删除预约地点
    /**
    *   删除预约地点
    *  @param id            预约地点记录ID，在更新的时候需要传，新建的时候不需要或传0
    *  @param completion  结果回调
    */
    class func deleteConsultAddress(id: String = "0", completion: (succeed : Bool!, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/consultAddress/delete", parameters: paramsToJsonDataParams(["id" : id])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    completion(succeed: true, nil, nil);
                } else {
                    completion(succeed: false, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(succeed: false, error, nil)
            }
        }
    }
    //  获取常用预约地址
    /**
    *  获取常用预约地址
    *  @param id            预约地点记录ID，在更新的时候需要传，新建的时候不需要或传0
    *  @param completion  结果回调
    */
    class func getCommonUsed(completion: (NSDictionary? , NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/consultAddress/getCommonUsed", parameters:nil) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    let address = dictionary!["address"] as! NSDictionary
                    completion(address, nil, nil);
                } else {
                    completion(nil, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(nil, error, nil)
            }
        }
    }
}

//MARK:- 发起视频，向用户推送APNS消息
extension QNNetworkTool {
    //MARK: 发起视频，向用户推送APNS消息
    /**
    :param: orderNo     订单号
    */
    class func huanXingCall(orderNo : String, completion: (succeed : Bool!,NSDictionary?, NSError?, String?) -> Void) {
        requestPOST(kServerAddress + "/api/doctor/order/call", parameters: paramsToJsonDataParams(["orderNo" : orderNo])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    completion(succeed: true,dictionary, nil, nil);
                } else {
                    completion(succeed:false,nil, error, dictionary?["errorMsg"] as? String)
                }
            } else {
                completion(succeed:false,nil, error, nil)
            }
        }
    }
    
}
//MARK:- 视频通话相关
extension QNNetworkTool {
    //MARK: 获取聊天用户头像及昵称
    /**
    :param: id     用户id
    */
    class func huanXingUserInfo(id : String,completion: (NSDictionary?, NSError?) -> Void) {
        requestPOST(kXiTeServerAddress + "/api/doctor/user/info", parameters: paramsToJsonDataParams(["id" : id])) { (_, _, _, dictionary, error) -> Void in
            if dictionary != nil {
                if let errorCode = dictionary!["errorCode"]?.integerValue where errorCode == 0 {
                    completion(dictionary, nil);
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
}

//MARK:-网关控制
typealias CustomBlock = (AnyObject) -> Void
var FinishBock:CustomBlock?
extension QNNetworkTool:AsyncUdpSocketDelegate,AsyncSocketDelegate{
    /**
      局域网内搜索网关
     
     :param: UDP 广播
     */
    class func scanLocationNet(udpStr: String,completion: CustomBlock) {
        let ipAddress =  GetWiFiInfoHelper.getIPAddress(true)//192.168.5.23
        let arr = ipAddress.componentsSeparatedByString(".") as NSArray
        var index = 0
        let mulArr = NSMutableArray()
        for str in arr {
            index = index + 1
            if index < arr.count {
                mulArr.addObject(str)
            }
            if index == arr.count {
                mulArr.addObject("255")
            }
            
        }
        let result = mulArr.componentsJoinedByString(".")
        
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do{
            let datastr = "0xFF0x040x330xCA"
            let data = datastr.dataUsingEncoding(NSUTF8StringEncoding)
//            try sock?.bindToPort(33632)
//            try sock?.joinMulticastGroup(result)
            sock?.sendData(data, toHost: result, port: 33632, withTimeout: -1, tag: 1)
            
        } catch {
            print("error")
        }

//         var udpsock = AsyncUdpSocket(delegate: self)
//        if (udpsock == nil){
//            udpsock = AsyncUdpSocket(delegate: self)
//        }
//        do{
//            //            try sock!.bindToPort(33632)
////             try udpsock!.enableBroadcast(true) // Also tried without this line
//            let datastr = "0xFF0x040x330xCA"
//            let data = datastr.dataUsingEncoding(NSUTF8StringEncoding)
//            udpsock?.sendData(data, toHost: result, port: 80, withTimeout: 1, tag: 1)
//        } catch {
//            print("error")
//        }

    }

    /**
     网关设置-验证设备管理密码
     
     :param: command 指令码:32
     :param: permit 输入的密码,固定 6 个字符
     */
    class func loginLocationNet(command: String,permit: String,completion: CustomBlock) {
       let socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost(addr, onPort: port)
            let request:String = "Arn.Preg:3302:"
            let data:NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1.0, tag: 0)
            socket.readDataWithTimeout(-1.0, tag: 0)
        } catch let e {
            completion("")
            print(e)
        }

    }
    /**
     网关设置-修改设备管理密码
     
     :param: command 指令码:33
     :param: permit_old 输入的密码,固定 6 个字符
     :param: permit_ new 输入的密码,固定 6 个字符
     */
    class func modifyLocationNet(command: String,permitOld: String,permitNew: String,completion: CustomBlock) {
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost(addr, onPort: port)
            let request:String = "Arn.Preg:3302:"
            let data:NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1.0, tag: 0)
            socket.readDataWithTimeout(-1.0, tag: 0)
        } catch let e {
            completion("")
            print(e)
        }
        
    }
    /**
     设备管理-获取所有设备信息
     
     :param: command 指令码:30
     */
    class func equmentslist(command: String,completion: CustomBlock) {
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost(addr, onPort: port)
            let request:String = "Arn.Preg:3302:"
            let data:NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1.0, tag: 0)
            socket.readDataWithTimeout(-1.0, tag: 0)
        } catch let e {
            completion("")
            print(e)
        }
        
    }
    /**
     设备管理-修改各设备的信息
     
     :param: command 指令码:30
     */
    class func modifyEqument(command: String,completion: CustomBlock) {
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost(addr, onPort: port)
            let request:String = "Arn.Preg:3302:"
            let data:NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1.0, tag: 0)
            socket.readDataWithTimeout(-1.0, tag: 0)
        } catch let e {
            completion("")
            print(e)
        }
        
    }

    class func test(completion: CustomBlock){
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        do {
            try socket.connectToHost("192.168.11.101", onPort: port)
            
           let str = toJsonDataParams(["command" : "36","dev_addr" : "25678","dev_type" : "3","work_status" : "60"])
            
//            let request:String = "Arn.Preg:3302:"
            
            let data:NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!
            socket.writeData(data, withTimeout: -1, tag: 0)
            socket.readDataWithTimeout(-1, tag: 0)
        } catch let e {
            completion("")
            print(e)
        }

    }

    //MARK:- Delegate method
    func onUdpSocket(cbsock:AsyncUdpSocket!,didReceiveData data: NSData!){
        print("Recv...")
        print(data)
        FinishBock!(data!)
        cbsock.receiveWithTimeout(10, tag: 0)
    }
    func onUdpSocket(sock: AsyncUdpSocket!, didReceiveData data: NSData!, withTag tag: Int, fromHost host: String!, port: UInt16) -> Bool {
        FinishBock!(data!)
        return true
    }
    func socket(socket : GCDAsyncSocket, didReadData data:NSData, withTag tag:UInt16)
    {
        let response = NSString(data: data, encoding: NSUTF8StringEncoding)
        FinishBock!(response!)
        print("Received Response")
    }
    
    func socket(socket : GCDAsyncSocket, didConnectToHost host:String, port p:UInt16)
    {
        FinishBock!(host)
        print("Connected to \(host) on port \(p).")
    }
    func onUdpSocket(sock: AsyncUdpSocket!, didNotSendDataWithTag tag: Int, dueToError error: NSError!) {
        print("Connected to")
    }
}






