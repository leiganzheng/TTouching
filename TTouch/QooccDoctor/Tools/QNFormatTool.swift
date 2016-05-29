//
//  QNFormatTool.swift
//  QooccHealth
//
//  Created by LiuYu on 15/4/27.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import Foundation


/**
*  //MARK:- 格式化工具
*/
class QNFormatTool: NSObject {
}


private let defaultDateInputFormat = "yyyy-MM-dd HH:mm:ss"
private let defaultDateOutputFormat = "MM-dd HH:mm"
/**
*  @author LiuYu, 15-04-27 08:04:47
*
*  //MARK:- 时间格式化工具
*/
extension QNFormatTool {
    
    /**
    将时间字符串转化成时间对象
    
    :param: dateString 时间字符串
    :param: format     格式
    
    :returns: 时间
    */
    class func date(dateString: String, format: String = defaultDateInputFormat) -> NSDate? {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.dateFromString(dateString)
    }
    
    /**
    将时间转换成时间字符串
    
    :param: date   时间对象
    :param: format 转换出来的时间字符串格式
    
    :returns: 时间字符串
    */
    class func dateString(date: NSDate, format: String = defaultDateOutputFormat) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(date)
    }
    
    /**
    将时间字符串按一定的格式转换
    
    :param: dateString   输入时间字符串
    :param: inputFormat  输入时间字符串的格式
    :param: outputFormat 输出时间字符串的格式
    
    :returns: 转换后的时间字符串
    */
    class func dateString(dateString: String, inputFormat: String = defaultDateInputFormat, outputFormat: String = defaultDateOutputFormat) -> String? {
        if let date = self.date(dateString, format: inputFormat) {
            return self.dateString(date, format: outputFormat)
        }
        return nil
    }
    
    /**
    将时间字符串按一定的格式转换
    
    :param: dateString   输入字符串日期
    :param: inputFormat  输入格式
    :param: refrenceDate 参考日期
    */
    class func dateQNString(dateString: String, inputFormat: String = defaultDateInputFormat, refrenceDate: NSDate = NSDate()) -> String? {
        return self.dateQNString(self.date(dateString, format: inputFormat)!, refrenceDate: refrenceDate)
    }
    
    /**
    将时间字符串按一定的格式转换
    
    :param: date         输入日期
    :param: refrenceDate 参考时间
    */
    class func dateQNString(date: NSDate, refrenceDate: NSDate = NSDate()) -> String? {
        // 获取年月日
        let components1 = NSCalendar.currentCalendar().components([NSCalendarUnit.Day, .Month , .Year], fromDate: date)
        let components2 = NSCalendar.currentCalendar().components([.Day , .Month , .Year], fromDate: refrenceDate)
        
        if components1.year != components2.year { // 年不同，全部显示
            return QNFormatTool.dateString(date, format: "yyyy-MM-dd HH:mm")
        }
        else if components1.month != components2.month || components1.day != components2.day { // 年相同，日期不同
            return QNFormatTool.dateString(date, format: "MM-dd HH:mm")
        }
        else { // 同一天的
            return QNFormatTool.dateString(date, format: "HH:mm")
        }
    }
    /**
    将时间字符串按当前时间差转换
    
    :param: dateStr         输入日期
    :param: refrenceDate 参考时间
    */
    class func dateQNTimeDifferenceFromNow(dateStr: String, refrenceDateStr: String) -> String?{
        let dateForm = NSDateFormatter()
         dateForm.dateFormat = refrenceDateStr
        if let da = dateForm.dateFromString(dateStr){
//            计算时间差模块：
            let now = NSDate()
            //now即为现在的时间，由于后面的NSCalendar可以匹配系统日期所以不用设置local
            let das = NSCalendar.currentCalendar()
            //new 一个 NSCalendar
            let flags: NSCalendarUnit = [.NSYearCalendarUnit , .NSMonthCalendarUnit , .NSDayCalendarUnit, .NSHourCalendarUnit , .NSMinuteCalendarUnit]
            //设置格式
            let nowCom = das.components(flags, fromDate: now)
            let timeCom = das.components(flags, fromDate: da)
            //创建当前和需要计算的components
            //components有之前设置的格式的各种参数
            if timeCom.year == nowCom.year{
                if timeCom.month == nowCom.month {
                    if timeCom.day == nowCom.day{
                        if timeCom.hour == nowCom.hour{
                            return "\(nowCom.minute - timeCom.minute)分钟前"
                        }else{
                            return "今天 \(timeCom.hour):\(timeCom.minute)"
                        }
                    }else{
                        if nowCom.day - timeCom.day == 1{
                            return "昨天 \(timeCom.hour):\(timeCom.minute)"
                        }else{
                            return "\(nowCom.day - timeCom.day)天前"
                        }
                    }
                }else{
                    return "\(nowCom.month - timeCom.month)月前"
                }
                
            }else{
                return dateStr
            }
        }
        return nil
    }
}


/**
*  @author LiuYu, 15-04-27 08:04:38
*
*  //MARK:- 消息未读数的格式化显示
*/
extension QNFormatTool {
    class func notReadCount(count: Int) -> String? {
        switch count {
        case 1...99:
            return String(count)
        case 100..<Int.max:
            return "99+"
        default:
            return nil
        }
    }
}











