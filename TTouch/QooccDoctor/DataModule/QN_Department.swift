//
//  QN_Department.swift
//  QooccDoctor
//
//  Created by haijie on 15/9/12.
//  Copyright (c) 2015年 juxi. All rights reserved.
//

import UIKit

//科室模型
class QN_Department: QN_BaseDataModel, QN_DataModelProtocol {
    var id : String!      //ID
    var  name : String!   //名
    var  child : NSMutableArray   //
    
    required init!(_ dictionary: NSDictionary) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.child = NSMutableArray(capacity: 0)
        if let array:NSArray = dictionary["child"] as? NSArray{
            for  dic in array {
                self.child.addObject(QN_DepartmentChild(dic as! NSDictionary))
            }
        }
        super.init(dictionary)
    }
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey:"id")
        dictionary.setValue(self.name, forKey:"name")
        dictionary.setValue(self.child, forKey:"child")
        return dictionary
    }
    //病症初始化
    class func getDepartmentData() -> NSMutableArray{
        var dataArray : NSArray!
        let leftArrays : NSMutableArray = NSMutableArray()
        if let areaFilePath = NSBundle.mainBundle().pathForResource("department", ofType: "json"), let areaData = NSData(contentsOfFile: areaFilePath) {
            do {
                dataArray = try NSJSONSerialization.JSONObjectWithData(areaData, options: NSJSONReadingOptions()) as? NSArray
            }catch{
                
            }
        }
        
        for(var i : Int = 0 ;i < dataArray.count; i++ ) {
            let dic : NSDictionary = dataArray[i] as! NSDictionary
            leftArrays.addObject(QN_Department(dic))
        }
        return leftArrays
    }
}
class QN_DepartmentChild: QN_BaseDataModel, QN_DataModelProtocol {
    var id : String!      //ID
    var name : String!    //名字
    required init!(_ dictionary: NSDictionary) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        super.init(dictionary)
    }
    
    func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.id, forKey:"id")
        dictionary.setValue(self.name, forKey:"name")
        return dictionary
    }
}

