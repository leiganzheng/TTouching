//
//  UIImageViewWebCacheExtension.swift
//  UIImageViewDemo
//
//  Created by LeiGanZheng on 14/12/9.
//  Copyright (c) 2014年 Liuyu. All rights reserved.
//

import UIKit

// 图片的缓存目录
private let imageCacheDirectoryPath = ((NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray).firstObject as! NSString).stringByAppendingPathComponent("UIImageWebCaches")

// 图片加载队列
private let imageLoadQueue = dispatch_queue_create("com.ly.imageLoadQueue", DISPATCH_QUEUE_SERIAL)

// 挂起一小段时间，避免一次发出太多的任务给主线程而造成主线程卡顿
private let sleep = { () in
    usleep(50000/*微秒*/)
}


/**
*  扩展UIImageView，使他支持下载网络图片并在下载完成后显示
*  注意 1： 不要使用 accessibilityIdentifier， 已经使用 accessibilityIdentifier 来对 imageUrl 进行保存
*  注意 2： 如果使用 image = , 有跟imageUrl混用的情况，请先将 .imageUrl = nil, 然后在做 .image =
*/
extension UIImageView {
    
//    var _imageUrl:String?
    var imageUrl:String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.setImageUrl(newValue, placeholderImage: nil)
        }
    }
    
    
    /**
    //MARK:- 异步设置本地图片
    
    :param: imageFilePath 本地图片路径
    */
    func setImageInBackground(imageFilePath: NSString) {
        // 已经是本张图片了，则返回
        if self.accessibilityIdentifier != nil && self.accessibilityIdentifier == imageFilePath {
            return
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(imageFilePath as String) {
            self.accessibilityIdentifier = imageFilePath as String
            dispatch_async(imageLoadQueue, { [weak self]() -> Void in
                if let image = UIImage(contentsOfFile: imageFilePath as String) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        if self?.accessibilityIdentifier != nil {
                            if self?.accessibilityIdentifier == imageFilePath {
                                self?.image = image
                            }
                        }
                    })
                    sleep()
                }
            })
        }
        else {
            self.accessibilityIdentifier = ""
            self.image = nil
        }
    }
    
    /*!
    //MARK:- 设置网络图片
    
    :param: imageUrl         网络图片的Url
    :param: placeholderImage 默认图片
    */
    func setImageUrl(imageUrl: NSString?, placeholderImage: UIImage?) {
        // 下载提示框
        var activityView = self.viewWithTag(10001) as? UIActivityIndicatorView
        
        if imageUrl == nil {
            self.image = placeholderImage
            self.accessibilityIdentifier = ""
            activityView?.removeFromSuperview()
            return
        }
        
        // 已经在加载本张图片了，则返回
        if self.accessibilityIdentifier != nil && self.accessibilityIdentifier == imageUrl! {
            return
        }

        // 1. 先配置默认图片
        self.image = placeholderImage
        self.accessibilityIdentifier = imageUrl! as String
        
        // 加载本地图片的代码
        let loadLocalImage = { [weak self](imageUrl: String, imageData: NSData?) -> Void in
            if self != nil && UIImageView.existsCache(imageUrl) {
                if let image = UIImageView.image((imageData != nil ? imageData! : UIImageView.cacheData(imageUrl)!), pathExtension: (NSURL(string: imageUrl)?.pathExtension)!) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        if self?.accessibilityIdentifier != nil && self?.accessibilityIdentifier == imageUrl {
                            activityView?.removeFromSuperview()
                            self?.image = image
                        }
                    })
                    sleep()
                }
            }
        }
        
        // 2. 然后优先使用本地缓存
        if UIImageView.existsCache(imageUrl! as String) {
            dispatch_async(imageLoadQueue, {() in
                loadLocalImage(imageUrl! as String, nil)
            })
            
            return
        }
        
        // 3. 如果没有本地，则去下载
        // 配置下载提示框
        if placeholderImage == nil {
            self.backgroundColor = UIColor(white: 0, alpha: 0.1)
            if activityView == nil {
                activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                activityView!.tag = 10001
                activityView!.center = CGPointMake(self.bounds.width/2.0, self.bounds.height/2.0)
                activityView!.startAnimating()
                self.addSubview(activityView!)
            }
        }
        
        // 4. 下载，下载完成后刷新UI，显示
        if self.accessibilityIdentifier != nil {
            UIImageView.imageDataFromUrl(self.accessibilityIdentifier!, completionQueue: imageLoadQueue, completionHandler: {(imageData: NSData?, url: String) in
                loadLocalImage(imageUrl! as String, imageData)
            })
        }
    }
    
    /*!
    *  获取图片
    *
    *  @param NSData 图片数据
    *  @param String 扩展名
    */
    private class func image(imageData: NSData, pathExtension: String) -> UIImage? {
        switch pathExtension.lowercaseString {
        case "gif":
            return UIImage.gifImage(imageData)
        case "jpg", "png":
            fallthrough
        default:    
            return UIImage(data: imageData)
        }
    }
    
    /*!
    *  设置图片
    *
    *  @param NSData 图片数据
    *  @param String 扩展名
    */
    private func setImage(imageData: NSData, pathExtension: String) {
        self.image = UIImageView.image(imageData, pathExtension: pathExtension)
    }
    
    /*!
    将url转换成key，key是用来做文件名用的
    
    :param: url
    */
    private class func key(str: String) -> String {
        let cStr = (str as NSString).UTF8String
        let buffer = UnsafeMutablePointer<UInt8>.alloc(16)
        CC_MD5(cStr,(CC_LONG)(strlen(cStr)), buffer)
        let md5String = NSMutableString()
        for i in 0..<16 {
            md5String.appendFormat("%X2", buffer[i])
        }
        
        free(buffer)
        return md5String as String
    }
    
    /*!
    //MARK:- 判断缓存是否存在
    
    :param: url
    
    :returns: 如果存在返回true，否则返回 false
    */
    class func existsCache(url: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(self.cachePath(url) as String)
    }
    
    /*!
    //MARK:- 获取缓存中的数据
    
    :param: url
    
    :returns: 如果存在则返回，否则返回nil
    */
    class func cacheData(url: String) -> NSData? {
        return NSData(contentsOfFile: self.cachePath(url) as String)
    }
    
    /*!
    //MARK:- 通过url获取本地缓存路径
    
    :param: url
    
    :returns: 返回本地缓存路径，不管本地有没有都会返回
    */
    class func cachePath(url: String) -> NSString {
        return imageCacheDirectoryPath+NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(self.key(url)).absoluteString
    }
    
    /*!
    缓存数据
    
    :param: url  数据的url，取的时候对应
    :param: data 数据
    */
    private class func saveData(url: String, data: NSData) {
        if !NSFileManager.defaultManager().fileExistsAtPath(imageCacheDirectoryPath) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(imageCacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                
            }
           
        }
        
        if data.length > 0 {
            data.writeToFile(self.cachePath(url) as String, atomically: true)
        }
    }
    
    /*!
    //MARK:- 清除所有的缓存
    */
    class func removeAllCaches() {
        if NSFileManager.defaultManager().fileExistsAtPath(imageCacheDirectoryPath) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(imageCacheDirectoryPath)
            }catch{
                
            }
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(imageCacheDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                
            }
        }
    }
    
    /*!
    //MARK:- 清除指定缓存
    */
    class func removeCache(url: String) {
        if self.existsCache(url) {
            do {
              try  NSFileManager.defaultManager().removeItemAtPath(self.cachePath(url) as String)
            }catch{
                
            }
            
        }
    }
    
    /**
    //MARK:- 异步下载图片（返回下载图片NSData，有进行缓存）
    
    :param: urlString         下载地址
    :param: completionHandler 下载完成回调到主线程
    */
    class func imageDataFromUrl(urlString: String, completionQueue: dispatch_queue_t?, completionHandler:((imageData: NSData?, url: String) -> ())?) {
        let completionQueueT: dispatch_queue_t! = completionQueue == nil ? dispatch_get_main_queue() : completionQueue!
        let completionHandlerInMainQueue = { (imageData: NSData?, url: String) -> Void in
            if completionHandler != nil {
                dispatch_async(completionQueueT, { () in
                    completionHandler!(imageData: imageData, url: url)
                })
            }
        }
        
        dispatch_async(imageLoadQueue, { () in
            // 已经缓存好了数据
            if let data = self.cacheData(urlString) {
                completionHandlerInMainQueue(data, urlString)
                return
            }
            
            // 缓存中没有数据，开始下载数据
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error != nil || !(data!.length > 0)) {
                    completionHandlerInMainQueue(nil, urlString)
                    return
                }
                
                if (data != nil) {
                    self.saveData(urlString, data: data!) // 保存到本地
                    completionHandlerInMainQueue(data, urlString)
                    return
                }
            }).resume()
        })
    }
}