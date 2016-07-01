//
//  PersonManager.swift
//  SaupFMDB
//
//  Created by 卲 鵬 on 15/9/1.
//  Copyright (c) 2015年 pshao. All rights reserved.
//

import UIKit

class DBManager: NSObject {
 
    let dbPath:String
    let dbBase:FMDatabase

    
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
        
        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        let path = (documentsFolder as NSString).stringByAppendingPathComponent("test.sqlite")
        self.dbPath = path
        //创建数据库
        dbBase =  FMDatabase(path: self.dbPath as String)
        
        print("path: ---- \(self.dbPath)", terminator: "")
        
        //打开数据库
        if dbBase.open(){
            
            let createSql:String = "CREATE TABLE IF NOT EXISTS T_Person (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, pid integer,name TEXT,height REAL)"
            
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
    func addPerson(p:Device) {
        
        dbBase.open();
        
        let arr:[AnyObject] = [p.pid!,p.name!,p.height!];
        
        if !self.dbBase.executeUpdate("insert into T_Person (pid ,name, height) values (?, ?, ?)", withArgumentsInArray: arr) {
                print("添加1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
                print("添加1条数据成功！: \(p.pid)")

        }
        
        dbBase.close();
    }
    
    
    // MARK: >> 删
    func deletePerson(p:Device) {
        
        dbBase.open();
        
        if !self.dbBase.executeUpdate("delete from T_Person where pid = (?)", withArgumentsInArray: [p.pid!]) {
            print("删除1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("删除1条数据成功！: \(p.pid)")
            
        }
        dbBase.close();

        
    }
    
    // MARK: >> 改
    func updatePerson(p:Device) {
        dbBase.open();

        let arr:[AnyObject] = [p.name!,p.height!,p.pid!];
  
        
        if !self.dbBase .executeUpdate("update T_Person set name = (?), height = (?) where pid = (?)", withArgumentsInArray:arr) {
            print("修改1条数据失败！: \(dbBase.lastErrorMessage())")
        }else{
            print("修改1条数据成功！: \(p.pid)")
            
        }
        dbBase.close();

    }
    
    // MARK: >> 查
    func selectPersons() -> Array<Device> {
        dbBase.open();
        var persons=[Device]()
        
            if let rs = dbBase.executeQuery("select pid, name, height from T_Person", withArgumentsInArray: nil) {
                while rs.next() {
                    
                    let pid:NSNumber = NSNumber(int:rs.intForColumn("pid"))
                    let name:String = rs.stringForColumn("name") as String
                    let height:Double = rs.doubleForColumn("height") as Double
                    
                    let p:Device = Device(pid: pid, name: name, height: height)
                    persons.append(p)
                }
            } else {
                
            print("查询失败 failed: \(dbBase.lastErrorMessage())")
                
            }
        dbBase.close();

        return persons
        
    }


    // MARK: >> 保证线程安全
    // TODO: 示例-增,查
    //FMDatabaseQueue这么设计的目的是让我们避免发生并发访问数据库的问题，因为对数据库的访问可能是随机的（在任何时候）、不同线程间（不同的网络回调等）的请求。内置一个Serial队列后，FMDatabaseQueue就变成线程安全了，所有的数据库访问都是同步执行，而且这比使用@synchronized或NSLock要高效得多。
    
    func safeaddPerson(p:Device){
        
        // 创建，最好放在一个单例的类中
        let queue:FMDatabaseQueue = FMDatabaseQueue(path: self.dbPath)
        
        queue.inDatabase { (db:FMDatabase!) -> Void in
            
            //You can do something in here...
            db.open();
            
            //增
            let arr:[AnyObject] = [p.pid!,p.name!,p.height!];
    
            if !self.dbBase.executeUpdate("insert into T_Person (pid ,name, height) values (?, ?, ?)", withArgumentsInArray: arr) {
                print("添加1条数据失败！: \(db.lastErrorMessage())")
            }else{
                print("添加1条数据成功！: \(p.pid)")
                
            }
            //查
            if let rs = db.executeQuery("select pid, name, height from T_Person", withArgumentsInArray: nil) {
                while rs.next() {
                    let pid:Int32 = rs.intForColumn("pid") as Int32
                    let name:String = rs.stringForColumn("name") as String
                    let height:Double = rs.doubleForColumn("height") as Double
                    print("pid:\(pid),name:\(name)", terminator: "");
                }
            } else {
                print("查询失败 failed: \(db.lastErrorMessage())")
            }
            db.close();

        }
    }
}
