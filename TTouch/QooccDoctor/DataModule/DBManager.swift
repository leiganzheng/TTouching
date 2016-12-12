//
//  PersonManager.swift
//  SaupFMDB
//
//  Created by lei on 15/9/1.
//  Copyright (c) 2015年 pshao. All rights reserved.
//

import UIKit

class DBManager: NSObject {
 
    let dbPath:String
    let dbBase:FMDatabase
    var ip:String
    
    
    // MARK: >> 单例化
    class func shareInstance()->DBManager{
        struct psSingle{
            static var onceToken:dispatch_once_t = 0;
            static var instance:DBManager? = nil
        }
        //保证单例只创建一次
        dispatch_once(&psSingle.onceToken,{
            psSingle.instance = DBManager()
        })
        return psSingle.instance!
    }
    
    
    // MARK: >> 创建数据库，打开数据库
    override init() {
        self.ip = ""
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (documentsFolder as NSString).stringByAppendingPathComponent("TTouching.sqlite")
        self.dbPath = path
        //创建数据库
        dbBase =  FMDatabase(path: self.dbPath as String)
        
        print("path: ---- \(self.dbPath)", terminator: "")
        
//        //打开数据库
//        if dbBase.open(){
//            
//            let createSql:String = "CREATE TABLE IF NOT EXISTS T_Device (address TEXT,dev_type INTEGER, work_status INTEGER,dev_name TEXT ,dev_status INTEGER, dev_area TEXT,belong_area TEXT,is_favourited INTEGER, icon_url TEXT);"
//            
//            if dbBase.executeUpdate(createSql, withArgumentsInArray: nil){
//                
//                print("数据库创建成功！", terminator: "")
//            
//            }else{
//                
//                print("数据库创建失败！failed:\(dbBase.lastErrorMessage())", terminator: "")
//            
//            }
//        }else{
//                print("Unable to open database!", terminator: "")
//        
//        }
    }
    // MARK: >> 建立数据表
    func createTable(name: String) {
        //打开数据库
        if dbBase.open(){
            
            let createSql:String = NSString(format: "CREATE TABLE IF NOT EXISTS %@ (address TEXT INTEGER NOT NULL PRIMARY KEY ,dev_type INTEGER, work_status INTEGER,dev_name TEXT ,dev_status INTEGER, dev_area TEXT,belong_area TEXT,is_favourited INTEGER, icon_url TEXT);",name) as String
            
            if dbBase.executeUpdate(createSql, withArgumentsInArray: nil){
                
                print("数据库创建成功！", terminator: "")
                
            }else{
                
                print("数据库创建失败！failed:\(dbBase.lastErrorMessage())", terminator: "")
                
            }
        }else{
            print("Unable to open database!", terminator: "")
            
        }

    }
    
    // MARK: >> 增
    func add(d:Device) {
        
        dbBase.open();
        
        let arr:[AnyObject] = [d.address!,d.dev_type!,d.work_status!,d.dev_name!,d.dev_status!,d.dev_area!,d.belong_area!,d.is_favourited!,d.icon_url!];
        
        if !self.dbBase.executeUpdate("insert into T_Device (address ,dev_type, work_status,dev_name ,dev_status, dev_area,belong_area ,is_favourited, icon_url) values (?, ?, ?,?, ?, ?,?, ?, ?)", withArgumentsInArray: arr) {
                print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
                print("添加1条数据成功！: \(d.address)")

        }
        
        dbBase.close();
    }
    
    
    // MARK: >> 删
    func deleteData(d:Device) {
        
        dbBase.open();
        
        if !self.dbBase.executeUpdate("delete from T_Device where address = (?)", withArgumentsInArray: [d.address!]) {
            print("删除1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("删除1条数据成功！: \(d.address)")
            
        }
        dbBase.close();

        
    }
    
    // MARK: >> 改
    func update(area:String,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update T_Device set dev_area = (?) WHERE address = ? ", area,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();

    }
    // MARK: >> 改
    func updateName(name:String,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update T_Device set dev_name = (?) WHERE address = ? ", name,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }
    // MARK: >> 改
    func updateIcon(image:NSData,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update T_Device set icon_url = (?) WHERE address = ? ", image,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }


    // MARK: >> 查
    func selectDatas() -> Array<Device> {
        dbBase.open();
        var devices=[Device]()
        
            if let rs = dbBase.executeQuery("select address,dev_type,work_status,dev_name,dev_status,dev_area,belong_area,is_favourited,icon_url from T_Device", withArgumentsInArray: nil) {
                while rs.next() {
                    
                    let address:String = rs.stringForColumn("address")
                    let dev_type:Int = Int(rs.intForColumn("dev_type"))
                    let work_status:Int = Int(rs.intForColumn("work_status"))
                    
                    let dev_name:String = rs.stringForColumn("dev_name")
                    let dev_status:Int = Int(rs.intForColumn("dev_status"))
                    let dev_area:String = rs.stringForColumn("dev_area")
                    
                    let belong_area:String = rs.stringForColumn("belong_area")
                    let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                    let icon_url:NSData = rs.dataForColumn("icon_url")
                    
                    let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status, dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)
                    devices.append(d)
                }
            } else {
                
            print("查询失败 failed: \(dbBase.lastErrorMessage())")
                
            }
        dbBase.close();

        return devices
        
    }
    // MARK: >> 查
    func selectDataNotRepeat() -> Array<Device> {
        dbBase.open();
        var devices=[Device]()
        
        if let rs = dbBase.executeQuery("select address,dev_type,work_status,dev_name,dev_status,dev_area,belong_area,is_favourited,icon_url from T_Device  GROUP BY dev_type", withArgumentsInArray: nil) {
            while rs.next() {
                
                let address:String = rs.stringForColumn("address")
                let dev_type:Int = Int(rs.intForColumn("dev_type"))
                let work_status:Int = Int(rs.intForColumn("work_status"))
                
                let dev_name:String = rs.stringForColumn("dev_name")
                let dev_status:Int = Int(rs.intForColumn("dev_status"))
                let dev_area:String = rs.stringForColumn("dev_area")
                
                let belong_area:String = rs.stringForColumn("belong_area")
                let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                let icon_url:NSData = rs.dataForColumn("icon_url")
                
                let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status, dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)
                devices.append(d)
            }
        } else {
            
            print("查询失败 failed: \(dbBase.lastErrorMessage())")
            
        }
        dbBase.close();
        
        return devices
        
    }
    // MARK: >> 查
    func selectData(aera:String) -> String {
        dbBase.open();
        var temp:String?
        if let rs = dbBase.executeQuery("select address,dev_type,work_status,dev_name,dev_status,dev_area,belong_area,is_favourited,icon_url from T_Device  GROUP BY dev_type", withArgumentsInArray: nil) {
            while rs.next() {
                let dev_type:Int = Int(rs.intForColumn("dev_type"))
                let dev_area:String = rs.stringForColumn("dev_area")
                if dev_type == 2 && dev_area == aera {
                    temp = rs.stringForColumn("dev_name")
                }
                
            }
        } else {
            
            print("查询失败 failed: \(dbBase.lastErrorMessage())")
            
        }
        dbBase.close();
        return temp!
    }

    // MARK: >> 保证线程安全
    // TODO: 示例-增,查
    //FMDatabaseQueue这么设计的目的是让我们避免发生并发访问数据库的问题，因为对数据库的访问可能是随机的（在任何时候）、不同线程间（不同的网络回调等）的请求。内置一个Serial队列后，FMDatabaseQueue就变成线程安全了，所有的数据库访问都是同步执行，而且这比使用@synchronized或NSLock要高效得多。
    
    func safeadd(d:Device){
        
        // 创建，最好放在一个单例的类中
        let queue:FMDatabaseQueue = FMDatabaseQueue(path: self.dbPath)
        
        queue.inDatabase { (db:FMDatabase!) -> Void in
            
            //You can do something in here...
            db.open();
            let arr:[AnyObject] = [d.address!,d.dev_type!,d.work_status!,d.dev_name!,d.dev_status!,d.dev_area!,d.belong_area!,d.is_favourited!,d.icon_url!];
            
            if !self.dbBase.executeUpdate("insert into T_Device (address ,dev_type, work_status,dev_name ,dev_status, dev_area,belong_area ,is_favourited, icon_url) values (?, ?, ?,?, ?, ?,?, ?, ?)", withArgumentsInArray: arr) {
                print("添加1条数据失败！: \(db.lastErrorMessage())")
            }else{
                print("添加1条数据成功！: \(d.address)")
                
            }

//            //增
//            let arr:[AnyObject] = [p.pid!,p.name!,p.height!];
//    
//            if !self.dbBase.executeUpdate("insert into T_Device (pid ,name, height) values (?, ?, ?)", withArgumentsInArray: arr) {
//                print("添加1条数据失败！: \(db.lastErrorMessage())")
//            }else{
//                print("添加1条数据成功！: \(p.pid)")
//                
//            }
            //查
            if let rs = db.executeQuery("select address from T_Device", withArgumentsInArray: nil) {
                while rs.next() {
                    let address:String = rs.stringForColumn("address")
                    let dev_type:Int = Int(rs.intForColumn("dev_type"))
                    let work_status:Int = Int(rs.intForColumn("work_status"))
                    
                    let dev_name:String = rs.stringForColumn("dev_name")
                    let dev_status:Int = Int(rs.intForColumn("dev_status"))
                    let dev_area:String = rs.stringForColumn("dev_area")
                    
                    let belong_area:String = rs.stringForColumn("belong_area")
                    let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                    let icon_url:NSData = rs.dataForColumn("icon_url")
                    
                    let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status, dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)

                    print("address:\(d.address),name:\(d.dev_name)", terminator: "");
                }
            } else {
                print("查询失败 failed: \(db.lastErrorMessage())")
            }
            db.close();

        }
    }
}
