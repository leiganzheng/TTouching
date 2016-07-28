//
//  QN_Base.swift
//  QooccShow
//
//  Created by Leiganzheng on 14/11/4.
//  Copyright (c) 2014年 Private. All rights reserved.
//

import Foundation

// 所有数据模型都必须实现这个协议
protocol QN_Protocol : NSCoding, NSCopying {
    
    //MARK:- 根据dictionary初始化方法
    init!(_ dictionary: NSDictionary)
    
    //MARK:- 还原出dictionary
    func dictionary() -> NSDictionary
    
    //MARK:- 获取打印信息
    var description: String {get}
    
    
}

/// 所有数据模型都必须支持这个协议
protocol QN_DataModelProtocol : NSCoding, NSCopying {
    // 根据dictionary初始化方法 （ 相当于从数据源中读取 ）
    init!(_ dictionary: NSDictionary)
    // 还原出dictionary ( 相当与写数据源 ）  注意与 init!(_ dictionary: NSDictionary) 中的数据对应
    func dictionary() -> NSDictionary
}


/// 所有数据模型类的抽象基类
class QN_BaseDataModel: NSObject {
    
    // MARK: LyDataModelProtocol
    required init!(_ dictionary: NSDictionary) {
        super.init()
        assert(self is QN_DataModelProtocol, "\(self.classForCoder) 必须支持 LyDataModelProtocol")
    }
    
    // MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        self.init(aDecoder.decodeObject() as! NSDictionary)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject((self as! QN_DataModelProtocol).dictionary())
    }
    
    // MARK: NSCoping
    func copyWithZone(zone: NSZone) -> AnyObject {
        let aClass = self.classForCoder as! QN_BaseDataModel.Type
        return aClass.init((self as! QN_DataModelProtocol).dictionary())
    }
    
    // MARK: description
    override var description: String {
        return (self as! QN_DataModelProtocol).dictionary().description
    }
    
    
}

/**
*  所有数据模型类的抽象基类
*  数据模型必须实现的方法：
*  public required init(dictionary: NSDictionary)
*  public func dictionary() -> NSDictionary
*/
class QN_Base : NSObject, QN_Protocol {
    //MARK:- QN_Protocol
    required init!(_ dictionary: NSDictionary) {
//        // 先判断存在性
//        if !QN_Base.existStringValue(dictionary, "...") {
//                super.init(dictionary)
//                return nil
//        }      
//        // 所需要的数据都存在，则开始真正的数据初始化
//        super.init(dictionary)
    }
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
//        dictionary.addEntriesFromDictionary(super.dictionary());
        return dictionary
    }
    
    //MARK: NSCoding
    required convenience init(coder aDecoder: NSCoder) {
        self.init(aDecoder.decodeObject() as! NSDictionary)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.dictionary())
    }
    
    //MARK: NSCoping
    func copyWithZone(zone: NSZone) -> AnyObject {
        let aClass = self.classForCoder as! QN_Base.Type
        return aClass.init(self.dictionary())
    }
    
    //MARK: description
    override var description: String {
        return self.dictionary().description
    }
    
    
}


/**
*  //MARK:- 判断存在性的扩展
*/
extension QN_Base {
    /**
    判断 dictionary 中是否存在 key
    
    :param: dictionary 数据源
    :param: key        需要判断的key
    
    :returns: 如果存在，则返回 true， 不存在则返回 false
    */
    class func existValue(dictionary: NSDictionary, _ key: String) -> Bool {
        return dictionary[key] != nil
    }
    
    /**
    判断 dictionary 中是否存在 key
    
    :param: dictionary 数据源
    :param: keys       所有需要判断的key
    
    :returns: 如果都存在，则返回 true，  有一个或更多个不存在则返回 false
    */
    class func existValue(dictionary: NSDictionary, keys: String...) -> Bool {
        for key in keys {
            if !self.existValue(dictionary, key) { // 发现一个不存在的，则返回false
                return false
            }
        }
        
        return true
    }
    
    
}
