//
//  UIImageGifExtension.swift
//  UIImageViewDemo
//
//  Created by LeiGanZheng on 14/12/9.
//  Copyright (c) 2014年 Leiganzheng. All rights reserved.
//

import UIKit.UIImage
import ImageIO

/**
*  提供从Gif图片的Data生产gif的UIImage的方法
*/
extension UIImage {
    class func gifImage(gifImageData: NSData) -> UIImage? {
        let gif = parseGifImageData(gifImageData)
        if gif.images.count > 0 {
            return UIImage.animatedImageWithImages(gif.images, duration: gif.duration)
        }
        else {
            return UIImage(data: gifImageData)
        }
    }
}