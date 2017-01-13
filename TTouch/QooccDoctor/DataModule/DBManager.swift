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
    var TableOneName:String
    var TableDLightName:String
    
    
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
        self.TableOneName = ""
        self.TableDLightName = ""
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (documentsFolder as NSString).stringByAppendingPathComponent("TTouching.sqlite")
        self.dbPath = path
        //创建数据库
        dbBase =  FMDatabase(path: self.dbPath as String)
        
        print("path: ---- \(self.dbPath)", terminator: "")
        
    }
    // MARK: >> 建立数据表
    func createTable(name: String) {
        //打开数据库
        if dbBase.open(){
            
            let createSql:String = NSString(format: "CREATE TABLE IF NOT EXISTS %@ (address TEXT INTEGER NOT NULL PRIMARY KEY ,dev_type INTEGER, work_status INTEGER, work_status1 INTEGER,work_status2 INTEGER,dev_name TEXT ,dev_status INTEGER, dev_area TEXT,belong_area TEXT,is_favourited INTEGER, icon_url TEXT);",name) as String
            
            if dbBase.executeUpdate(createSql, withArgumentsInArray: nil){
                
                print("数据库创建成功！", terminator: "")
                
            }else{
                
                print("数据库创建失败！failed:\(dbBase.lastErrorMessage())", terminator: "")
                
            }
        }else{
            print("Unable to open database!", terminator: "")
            
        }

    }
    
    // MARK: >> 建立数据表
    func createTableDoubleLight(name: String) {
        //打开数据库
        if dbBase.open(){
            
            let createSql:String = NSString(format: "CREATE TABLE IF NOT EXISTS %@ (address TEXT INTEGER NOT NULL PRIMARY KEY ,dev_type INTEGER, work_status INTEGER, work_status1 INTEGER,work_status2 INTEGER);",name) as String
            
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
        
        let arr:[AnyObject] = [d.address!,d.dev_type!,d.work_status!,d.work_status1!,d.work_status2!,d.dev_name!,d.dev_status!,d.dev_area!,d.belong_area!,d.is_favourited!,d.icon_url!];
        
        if !self.dbBase.executeUpdate("insert into \(TableOneName) (address ,dev_type, work_status,work_status1,work_status2,dev_name ,dev_status, dev_area,belong_area ,is_favourited, icon_url) values (?, ?, ?,?, ?,?,?, ?,?, ?, ?)", withArgumentsInArray: arr) {
                print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
//               print("添加1条数据失败！: \(d.address)")
//               print("添加1条数据失败！: \(d.dev_name)")
        }else{
//            print("添加1条数据！: \(dbBase.lastErrorMessage())")
                print("添加1条数据成功！: \(d.dev_name)")

        }
        
        dbBase.close();
    }

    // MARK: >> 增
    func addLight(d:Device) {
        
        dbBase.open();
        
        let arr:[AnyObject] = [d.address!,d.dev_type!,d.work_status!,d.work_status1!,d.work_status2!,d.dev_name!,d.dev_status!,d.dev_area!,d.belong_area!,d.is_favourited!,d.icon_url!];
        
        if !self.dbBase.executeUpdate("insert into \(self.TableOneName) (address ,dev_type, work_status,work_status1,work_status2) values (?, ?, ?,?, ?)", withArgumentsInArray: arr) {
            print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
            //               print("添加1条数据失败！: \(d.address)")
            //               print("添加1条数据失败！: \(d.dev_name)")
        }else{
            //            print("添加1条数据！: \(dbBase.lastErrorMessage())")
            print("添加1条数据成功！: \(d.dev_name)")
            
        }
        
        dbBase.close();
    }

    
    
    // MARK: >> 删
    func deleteAll(){
        dbBase.open();
        if self.dbBase.executeUpdate("delete from \(self.TableOneName)") {
            print("删除数据成功！")
        }else{
             print("删除数据失败！: \(dbBase.lastErrorMessage())")
        }
        dbBase.close()
    }
    func deleteData(d:Device) {
        
        dbBase.open();
        
        if !self.dbBase.executeUpdate("delete from \(self.TableOneName) where address = (?)", withArgumentsInArray: [d.address!]) {
            print("删除1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("删除1条数据成功！: \(d.address)")
            
        }
        dbBase.close();

        
    }
    
    // MARK: >> 改
    func update(area:String,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(self.TableOneName) set dev_area = (?) WHERE address = ? ", area,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();

    }
    // MARK: >> 改
    func updateStatus(status:Int,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(self.TableOneName) set work_status = (?) WHERE address = ? ", status,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }
    // MARK: >> 改
    func updateStatus1(status:Int,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(TableDLightName) set work_status1 = (?) WHERE address = ? ", status,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }
    // MARK: >> 改
    func updateStatus2(status:Int,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(TableDLightName) set work_status2 = (?) WHERE address = ? ", status,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }


    // MARK: >> 改
    func updateFav(fav:Int,type:String,complete:(AnyObject) -> Void) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(self.TableOneName) set is_favourited = (?) WHERE address = ? ", fav,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
            complete(0)//失败
        }else{
            print("修改1条数据成功！: ")
            complete(1)
            
        }
        dbBase.close();
        
    }

    // MARK: >> 改
    func updateName(name:String,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(self.TableOneName) set dev_name = (?) WHERE address = ? ", name,type) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: ")
            
        }
        dbBase.close();
        
    }
    // MARK: >> 改
    func updateIcon(image:NSData,type:String) {
        dbBase.open();
        
        if !self.dbBase .executeUpdate("update \(self.TableOneName) set icon_url = (?) WHERE address = ? ", image,type) {
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
        
            if let rs = dbBase.executeQuery("select address,dev_type,work_status,work_status1,work_status2,dev_name,dev_status,dev_area,belong_area,is_favourited,icon_url from \(self.TableOneName)", withArgumentsInArray: nil) {
                while rs.next() {
                    
                    let address:String = rs.stringForColumn("address")
                    let dev_type:Int = Int(rs.intForColumn("dev_type"))
                    let work_status:Int = Int(rs.intForColumn("work_status"))
                    let work_status1:Int = Int(rs.intForColumn("work_status1"))
                    let work_status2:Int = Int(rs.intForColumn("work_status2"))
                    
                    let dev_name:String = rs.stringForColumn("dev_name")
                    let dev_status:Int = Int(rs.intForColumn("dev_status"))
                    let dev_area:String = rs.stringForColumn("dev_area")
                    
                    let belong_area:String = rs.stringForColumn("belong_area")
                    let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                    let icon_url:NSData = rs.dataForColumn("icon_url")
                    
                    let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status, work_status1: work_status1,work_status2: work_status2,dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)
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
        
        if let rs = dbBase.executeQuery("select address,dev_type,work_status,work_status1,work_status2,dev_name,dev_status,dev_area,belong_area,is_favourited,icon_url from \(self.TableOneName)  GROUP BY dev_type", withArgumentsInArray: nil) {
            while rs.next() {
                
                let address:String = rs.stringForColumn("address")
                let dev_type:Int = Int(rs.intForColumn("dev_type"))
                let work_status:Int = Int(rs.intForColumn("work_status"))
                let work_status1:Int = Int(rs.intForColumn("work_status1"))
                let work_status2:Int = Int(rs.intForColumn("work_status2"))
                
                let dev_name:String = rs.stringForColumn("dev_name")
                let dev_status:Int = Int(rs.intForColumn("dev_status"))
                let dev_area:String = rs.stringForColumn("dev_area")
                
                let belong_area:String = rs.stringForColumn("belong_area")
                let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                let icon_url:NSData = rs.dataForColumn("icon_url")
                
                let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status,work_status1: work_status1,work_status2: work_status2, dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)
                devices.append(d)
            }
        } else {
            
            print("查询失败 failed: \(dbBase.lastErrorMessage())")
            
        }
        dbBase.close();
        
        return devices
        
    }
    // MARK: >> 查
    func selectWorkStatus(address:String,flag:Int) -> Int {
        dbBase.open();
        var temp:Int = flag == 0 ? 100 : 200
        if let rs = dbBase.executeQuery("select work_status1,work_status2,dev_type,address from \(TableDLightName)  GROUP BY dev_type", withArgumentsInArray: nil) {
                while rs.next() {
                    
                    let dev_type:Int = Int(rs.intForColumn("dev_type"))
                    let dev_address:String = rs.stringForColumn("address")
                    if dev_type == 4 && dev_address == address {
                        if flag == 0 {
                            temp = Int(rs.stringForColumn("work_status1"))!
                        }else{
                            temp = Int(rs.stringForColumn("work_status2"))!
                        }
                    }
                    
                }
            } else {
                print("查询失败 failed: \(dbBase.lastErrorMessage())")
                
            }
        dbBase.close();
        return temp
    }
    // MARK: >> 查
    func selectData(aera:String) -> String {
        dbBase.open();
        var temp:String = ""
        if let rs = dbBase.executeQuery("select dev_type,dev_name,dev_area,icon_url from \(self.TableOneName)  GROUP BY dev_type", withArgumentsInArray: nil) {
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
        return temp
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
            let arr:[AnyObject] = [d.address!,d.dev_type!,d.work_status!,d.work_status1!,d.dev_name!,d.dev_status!,d.dev_area!,d.belong_area!,d.is_favourited!,d.icon_url!];
            
            if !self.dbBase.executeUpdate("insert into \(self.TableOneName) (address ,dev_type, work_status,work_status1,work_status2,dev_name ,dev_status, dev_area,belong_area ,is_favourited, icon_url) values (?, ?, ?,?, ?, ?,?,?, ?,?, ?)", withArgumentsInArray: arr) {
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
            if let rs = db.executeQuery("select address from \(self.TableOneName)", withArgumentsInArray: nil) {
                while rs.next() {
                    let address:String = rs.stringForColumn("address")
                    let dev_type:Int = Int(rs.intForColumn("dev_type"))
                    let work_status:Int = Int(rs.intForColumn("work_status"))
                    let work_status1:Int = Int(rs.intForColumn("work_status1"))
                    let work_status2:Int = Int(rs.intForColumn("work_status2"))
                    
                    let dev_name:String = rs.stringForColumn("dev_name")
                    let dev_status:Int = Int(rs.intForColumn("dev_status"))
                    let dev_area:String = rs.stringForColumn("dev_area")
                    
                    let belong_area:String = rs.stringForColumn("belong_area")
                    let is_favourited:Int = Int(rs.intForColumn("is_favourited"))
                    let icon_url:NSData = rs.dataForColumn("icon_url")
                    
                    let d:Device = Device(address: address, dev_type: dev_type, work_status: work_status, work_status1: work_status1, work_status2: work_status2,dev_name: dev_name, dev_status: dev_status, dev_area: dev_area, belong_area: belong_area, is_favourited: is_favourited, icon_url: icon_url)

                    print("address:\(d.address),name:\(d.dev_name)", terminator: "");
                }
            } else {
                print("查询失败 failed: \(db.lastErrorMessage())")
            }
            db.close();

        }
    }
}
