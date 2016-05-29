//
//  QN_CheckData.swift
//  QooccHealth
//
//  Created by 肖小丰 on 15/4/16.
//  Copyright (c) 2015年 Liuyu. All rights reserved.
//

import UIKit

/**
//MARK:-  体征数据模型（不含尿检数据）
*/
class QN_CheckData: QN_Base {
    
    private(set) var ownerId: String?       // 用户唯一标识
    private(set) var dataArray: NSArray?    // 详细值
    private(set) var dataCount: Int?        // 最近一次测量的当天的测量数据（最多为8个， 按8等分的取平均值）
    private(set) var launchDateTime: String?// 数据上传时间 yyyy-MM-dd HH:mm:ss
    //计步器
    private(set) var distance: Float?  //距离
    private(set) var calorie: Float?   //卡路里
    private(set) var duration: Float?  //持续时间
    private(set) var pedometer: Float? //步数
    private(set) var pedometerTarget: NSString? //任务目标步行数
    //脉率属性 / 心电图 /呼吸率
    private(set) var heartRate: Float?     // 心率值
    private(set) var breathRate: Float?    // 呼吸率
    private(set) var ecgScore: Float?      // 评分
    private(set) var data: NSArray?        // 脉率数组
    //心电图
    private(set) var ecgWaveUrl: String?   // 心电图路径（历史返回，现只会返回空）
    //血压
    private(set) var shrinkVal: Float?     // 收缩压/高压
    private(set) var diastolicVal: Float?  // 舒张压/低压
    private(set) var nibpScore: Float?     // 血压评分
    //血氧
    private(set) var saturation: Float?    // 血氧饱和度
    private(set) var pulseRate: Float?     // 脉率
    private(set) var spoScore: Float?      // 血氧评分
    //体温
    private(set) var tempOne: Float?       // 体温
    private(set) var tempScore: Float?     // 体温分数
    //血糖
    private(set) var gluValue: Float?      // 血糖值
    private(set) var gluScore: Float?      // 血糖分数
    private(set) var isLimosis: Bool?      // 血糖分类 0：空腹、1：非空腹
    private(set) var gluValueColor: Int?

    //尿检（由于属性较多单独出一个Model）
    
    
    required init!(_ dictionary: NSDictionary) {
        //初始化数据
        self.ownerId = dictionary["ownerId"] as? String
        self.dataCount = dictionary["dataCount"]?.integerValue
        self.dataArray = dictionary["data"] as? NSArray
        self.launchDateTime = dictionary["launchDateTime"] as? String ?? "-"
        //计步器
        self.distance = dictionary["distance"]?.floatValue ?? 0
        self.calorie = dictionary["calorie"]?.floatValue ?? 0
        self.duration = dictionary["duration"]?.floatValue ?? 0
        self.pedometer = dictionary["pedometer"]?.floatValue ?? 0
        self.pedometerTarget = dictionary["target"] as? NSString ?? "0"
        //脉率属性  / 心电图 / 呼吸率
        self.heartRate = dictionary["heartRate"]?.floatValue
        self.breathRate = dictionary["breathRate"]?.floatValue
        self.ecgScore = dictionary["ecgScore"]?.floatValue
        self.data = dictionary["detail"] as? [NSDictionary]
        //心电图
        self.ecgWaveUrl = dictionary["ecgWaveUrl"] as? String
       //血压
        self.shrinkVal = dictionary["shrinkVal"]?.floatValue
        self.diastolicVal = dictionary["diastolicVal"]?.floatValue
        self.nibpScore = dictionary["nibpScore"]?.floatValue
       //血氧
        self.saturation = dictionary["saturation"]?.floatValue
        self.pulseRate = dictionary["pulseRate"]?.floatValue
        self.spoScore = dictionary["spoScore"]?.floatValue
       //体温
        self.tempOne = dictionary["temp"]?.floatValue
        self.tempScore = dictionary["tempScore"]?.floatValue
       //血糖
        self.gluValue =  dictionary["gluValue"]?.floatValue ?? 0
        self.gluScore =  dictionary["gluScore"]?.floatValue ?? 0
        self.isLimosis = dictionary["gluType"]?.floatValue == 0 ? true : false
        self.gluValueColor = dictionary["color"]?.integerValue
        super.init(dictionary)
    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])
        //脉率属性 //呼吸率
        dictionary.setValue(self.ownerId, forKey:"ownerId")
        dictionary.setValue(self.heartRate, forKey:"heartRate")
        dictionary.setValue(self.breathRate, forKey:"breathRate")
        dictionary.setValue(self.ecgScore, forKey:"ecgScore")
        dictionary.setValue(self.dataCount, forKey:"dataCount")
        dictionary.setValue(self.dataArray, forKey:"dataArray")
        dictionary.setValue(self.launchDateTime, forKey:"launchDateTime")
        //心电图
        dictionary.setValue(self.ecgWaveUrl, forKey:"ecgWaveUrl")
        //血压
        dictionary.setValue(self.shrinkVal, forKey:"shrinkVal")
        dictionary.setValue(self.diastolicVal, forKey:"diastolicVal")
        dictionary.setValue(self.nibpScore, forKey:"nibpScore")
        //血氧
        dictionary.setValue(self.saturation, forKey:"saturation")
        dictionary.setValue(self.pulseRate, forKey:"plusRate")
        dictionary.setValue(self.spoScore, forKey:"spoScore")
        //体温
        dictionary.setValue(self.tempOne, forKey:"temp")
        dictionary.setValue(self.tempScore, forKey:"tempScore")
        //计步器
        dictionary.setValue(self.distance, forKey:"distance")
        dictionary.setValue(self.calorie, forKey:"calorie")
        dictionary.setValue(self.duration, forKey:"duration")
        dictionary.setValue(self.pedometer, forKey:"pedometer")
        dictionary.setValue(self.pedometerTarget, forKey:"target")
        //血糖
        dictionary.setValue(self.gluValue, forKey:"gluValue")
        dictionary.setValue(self.gluScore, forKey:"gluScore")
        dictionary.setValue(self.isLimosis, forKey:"isLimosis")
        dictionary.setValue(self.gluValueColor, forKey:"gluValueColor")
        //尿检
        return dictionary
    }

    
}

/**
//MARK:- 尿检数据
*/
class QN_UrineData: QN_Base {
    private(set) var ownerId: String?        //  用户唯一标识
    private(set) var launchDateTime: String? // 数据上传时间 yyyy-MM-dd HH:mm:ss
    private(set) var urineScore: Float? //分数
    //...Flag:是否正常:1：正常 2：不正常 3：偏高 4：偏低
    private(set) var uro: String?       //尿胆原结果
    private(set) var uroFlag: String?   //尿胆原是否正常，1(正常)/2(异常)
 
    private(set) var wbc: String?       //白细胞结果
    private(set) var wbcFlag: String?   //白细胞是否正常，1(正常)/2(异常)
    
    private(set) var bil: String?       //胆红素结果
    private(set) var bilFlag: String?   //胆红素是否正常，1(正常)/2(异常)
    
    private(set) var sg: String?        //比重结果
    private(set) var sgFlag: String?    //比重是否正常，1(正常)/2(异常)

    private(set) var glu: String?       //葡萄糖结果
    private(set) var gluFlag: String?   //葡萄糖是否正常，1(正常)/2(异常)

    private(set) var ph: String?        //酸碱度结果
    private(set) var phFlag: String?    //酸碱度是否正常，1(正常)/2(异常)

    private(set) var pro: String?       //蛋白质结果
    private(set) var proFlag: String?   //蛋白质是否正常，1(正常)/2(异常)

    private(set) var bld: String?       //血结果
    private(set) var bldFlag: String?   //血是否正常，1(正常)/2(异常)
    
    private(set) var nit: String?       //亚硝酸盐结果
    private(set) var nitFlag: String?   //亚硝酸盐是否正常，1(正常)/2(异常)
    
    private(set) var vc: String?        //抗坏血酸结果
    private(set) var vcFlag: String?    //抗坏血酸是否正常，1(正常)/2(异常)
    
    private(set) var ket: String?       //酮体结果
    private(set) var ketFlag: String?   //酮体是否正常，1(正常)/2(异常)

    
    required init!(_ dictionary: NSDictionary) {
        // 先判断存在性
        if !QN_Base.existValue(dictionary, keys: "ownerId", "urineScore", "uro", "launchDateTime", "wbc","wbcFlag","bil","bilFlag","sg","sgFlag","glu","gluFlag","ph","phFlag","pro","proFlag","bld","bldFlag","nit","nitFlag","vc","vcFlag","ket","ketFlag") {
            super.init(dictionary)
            return nil
        }
        self.ownerId = dictionary["ownerId"] as? String
        self.launchDateTime = dictionary["launchDateTime"] as? String
        self.urineScore = dictionary["urineScore"]?.floatValue
        
        self.uro = dictionary["uro"] as? String
        self.uroFlag = dictionary["uroFlag"]?.integerValue == 1 ? "正常" : "异常"

        self.wbc = dictionary["wbc"] as? String
        self.wbcFlag = dictionary["wbcFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.bil = dictionary["bil"] as? String
        self.bilFlag = dictionary["bilFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.sg = dictionary["sg"] as? String
        self.sgFlag = dictionary["sgFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.glu = dictionary["glu"] as? String
        self.gluFlag = dictionary["gluFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.ph = dictionary["ph"] as? String
        self.phFlag = dictionary["phFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.pro = dictionary["pro"] as? String
        self.proFlag = dictionary["proFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.bld = dictionary["bld"] as? String
        self.bldFlag = dictionary["bldFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.nit = dictionary["nit"] as? String
        self.nitFlag = dictionary["nitFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        self.vc = dictionary["vc"] as? String
        self.vcFlag = dictionary["vcFlag"]?.integerValue == 1 ? "正常" : "异常"

        self.ket = dictionary["ket"] as? String
        self.ketFlag = dictionary["ketFlag"]?.integerValue == 1 ? "正常" : "异常"
        
        super.init(dictionary)

    }
    
    override func dictionary() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.addEntriesFromDictionary(super.dictionary() as [NSObject : AnyObject])

        dictionary.setValue(self.ownerId, forKey:"ownerId")
        dictionary.setValue(self.launchDateTime, forKey:"launchDateTime")
        dictionary.setValue(self.urineScore, forKey:"urineScore")
        dictionary.setValue(self.uro, forKey:"uro")
        dictionary.setValue(self.uroFlag, forKey:"uroFlag")
        dictionary.setValue(self.wbc, forKey:"wbc")
        dictionary.setValue(self.wbcFlag, forKey:"wbcFlag")
        dictionary.setValue(self.bil, forKey:"bil")
        dictionary.setValue(self.bilFlag, forKey:"bilFlag")
        dictionary.setValue(self.sg, forKey:"sg")
        dictionary.setValue(self.sgFlag, forKey:"sgFlag")
        dictionary.setValue(self.glu, forKey:"glu")
        dictionary.setValue(self.gluFlag, forKey:"gluFlag")
        dictionary.setValue(self.ph, forKey:"ph")
        dictionary.setValue(self.phFlag, forKey:"phFlag")
        dictionary.setValue(self.pro, forKey:"pro")
        dictionary.setValue(self.proFlag, forKey:"proFlag")
        dictionary.setValue(self.bld, forKey:"bld")
        dictionary.setValue(self.bldFlag, forKey:"bldFlag")
        dictionary.setValue(self.nit, forKey:"nit")
        dictionary.setValue(self.nitFlag, forKey:"nitFlag")
        dictionary.setValue(self.vc, forKey:"vc")
        dictionary.setValue(self.vcFlag, forKey:"vcFlag")
        dictionary.setValue(self.ket, forKey:"ket")
        dictionary.setValue(self.ketFlag, forKey:"ketFlag")
        return dictionary
    }
    
    
}




