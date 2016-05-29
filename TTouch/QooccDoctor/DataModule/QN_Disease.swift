//
//  QN_Disease.swift
//  QooccHealth
//
//  Created by haijie on 15/9/1.
//  Copyright (c) 2015年 Juxi. All rights reserved.
//

import UIKit
//病症模型

class QN_Disease: QN_BaseDataModel, QN_DataModelProtocol {
    var id : String!      //ID
    var  name : String!   //名
    var  child : NSMutableArray   //
    
    required init!(_ dictionary: NSDictionary) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.child = NSMutableArray(capacity: 0)
        if let citysArray:NSArray = dictionary["child"] as? NSArray{
            for  cityDict in citysArray {
                self.child.addObject(QN_DiseaseChild(cityDict as! NSDictionary))
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
    class func getIllData() -> NSMutableArray{
        var areaFile : NSArray!
        let leftArrays : NSMutableArray = NSMutableArray()
        if let areaFilePath = NSBundle.mainBundle().pathForResource("ill", ofType: "json"), let areaData = NSData(contentsOfFile: areaFilePath) {
            
            do {
                areaFile = try NSJSONSerialization.JSONObjectWithData(areaData, options: NSJSONReadingOptions()) as? NSArray
            }catch{
                
            }
        }
      
        for(var i : Int = 0 ;i < areaFile.count; i++ ) {
            let dic : NSDictionary = areaFile[i] as! NSDictionary
            leftArrays.addObject(QN_Disease(dic))
        }
        return leftArrays
    }
}
class QN_DiseaseChild: QN_BaseDataModel, QN_DataModelProtocol {
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

