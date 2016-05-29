//
//  GifParser.swift
//  UIImageViewDemo
//
//  Created by LeiGanZheng on 14/12/9.
//  Copyright (c) 2014年 Liuyu. All rights reserved.
//

import UIKit
import ImageIO

/**
//MARK:- 解析Gif数据

:param: gifImageData 源数据

:returns: 返回 图片数组 和 总时间
*/
func parseGifImageData(gifImageData: NSData) -> (images: [UIImage], duration: NSTimeInterval) {
    var resultImage: UIImage?
    var duration: NSTimeInterval = 0.0
    
    // 分解GIF图片
    let source = CGImageSourceCreateWithData(gifImageData, nil)
    let count = CGImageSourceGetCount(source!)
    var images = [UIImage]()
    if count <= 1 {
        resultImage = UIImage(data: gifImageData)
        if resultImage != nil{
            images.append(resultImage!)
        }
    }
    else {
        for index in 0..<count {
            let image = CGImageSourceCreateImageAtIndex(source!,index,nil)
            duration = duration + NSTimeInterval(gifDelayTime(source!, index: index, minDelayTime: 0.1))
            let imageNew = UIImage(CGImage: image!, scale: UIScreen.mainScreen().scale, orientation: UIImageOrientation.Up)
            images.append(imageNew)
//            CGImageRelease(image)
        }
    }
    
    // 如果获取不到时间，按每秒10帧的速度播放
    if duration == 0.0 {
        duration = NSTimeInterval(count/size_t(10.0))
    }
//    CFRelease(source)
    
    return (images, duration)
}

/**
//MARK:- 获取Gif图片组某一帧的时长

:param: index  每帧
:param: source CGImageSourceRef

:returns: 每帧时间
*/
private func gifDelayTime(source: CGImageSourceRef, index: Int, minDelayTime: NSTimeInterval) -> NSTimeInterval {
    var delayTime = minDelayTime
    let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as! NSDictionary
    let gifProperties = properties[NSString(format: kCGImagePropertyGIFDictionary)] as! NSDictionary
    if let delayTimeUnclampedProp = gifProperties[NSString(format: kCGImagePropertyGIFUnclampedDelayTime)] as? NSNumber {
        delayTime = NSTimeInterval(delayTimeUnclampedProp)
    }
    else if let delayTimeProp = gifProperties[NSString(format: kCGImagePropertyGIFUnclampedDelayTime)] as? NSNumber {
        delayTime = NSTimeInterval(delayTimeProp)
    }
    
    if delayTime < minDelayTime {
        delayTime = minDelayTime
    }
//     CFRelease(cfFrameProperties)
    
    return delayTime
}