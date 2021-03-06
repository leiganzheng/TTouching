//
//  GateWayListViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaAsyncSocket

class GateWayListViewController: UIViewController, QNInterceptorProtocol, QNInterceptorNavigationBarShowProtocol,UITableViewDataSource, UITableViewDelegate {
    private var tableViewController: UITableViewController!
    var myTableView: UITableView! {
        return self.tableViewController?.tableView
    }
    var outSocket : OutSocket!
    var flags:NSMutableArray = []
    var dataS:NSMutableArray = []
    var flag = true
    var searchButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("查找网关", tableName: "Localization",comment:"jj")
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
//        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ [weak self](input) -> Void in
//            self?.fectchData()
//            })
        self.tableViewController.refreshControl?.addTarget(self, action: #selector(GateWayListViewController.pullData), forControlEvents: UIControlEvents.ValueChanged)
//        self.tableViewController.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新数据")
        self.myTableView.frame = CGRectMake(0, 30, self.view.bounds.width, screenHeight - 148)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth]
        self.myTableView.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
        
        searchButton = UIButton(frame: CGRectMake(10, self.myTableView.frame.size.height+4, screenWidth-20, 48))
        searchButton.setTitle(NSLocalizedString("选择", tableName: "Localization",comment:"jj"), forState: UIControlState.Normal)
        searchButton.backgroundColor = appThemeColor
        QNTool.configViewLayer(searchButton)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            var tag = false
            for temp in self.flags {
                if (temp as! Bool) == true {
                    tag = true
                }
            }
            if tag {
                let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
                QNTool.enterRootViewController(vc, animated: true)
            }else{
                QNTool.showPromptView(NSLocalizedString("选择网关", tableName: "Localization",comment:"jj"))
            }
            return RACSignal.empty()
        })
        self.view.addSubview(searchButton)
        
        
        //局域网内搜索网关
        outSocket = OutSocket()
        self.tableViewController.refreshControl?.beginRefreshing()
        
        self.fectchData()

    }
    func pullData(){
        self.fectchData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dataS.count == 0 ? 0 : UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flag == true {
            return 0
        }
        return dataS.count == 0 ? 1 : self.dataS.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.dataS.count==0 {
            let cellIdentifier = "Cell"
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            tableView.separatorStyle = .None
            let lb = UILabel(frame: CGRectMake(screenWidth/2-100,0,200,48))
            lb.text = NSLocalizedString("暂无数据,下拉重试", tableName: "Localization",comment:"jj")
            lb.textColor = UIColor.lightGrayColor()
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else{
            
            let cellId = "cell"
            var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            cell.contentView.backgroundColor = UIColor.whiteColor()
            let dict = dataS[indexPath.row] as! NSMutableDictionary
            cell.textLabel?.text = dict.allKeys[0] as? String
            if dataS.count == 1 {
                self.flags.replaceObjectAtIndex(0 , withObject: true)
                let dict = dataS[indexPath.row] as! NSMutableDictionary
                self.dataFeathc(dict)
            }
            let flag = self.flags[indexPath.row] as! Bool
            let icon = (flag==true) ? "pic_hd" : "Menu_Trigger_icon1"
            cell.imageView?.image = UIImage(named: icon)
            let searchButton:UIButton = UIButton(type: .Custom)
            searchButton.frame = CGRectMake(0, 5, 40, 30)
            searchButton.setImage(UIImage(named: "Manage_information_icon"), forState: .Normal)
            searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
                let vc = GateWayDetailViewController.CreateFromStoryboard("Main") as! GateWayDetailViewController
                vc.dataS = dict.allValues[0] as? NSMutableArray
                self?.navigationController?.pushViewController(vc, animated: true)
                return RACSignal.empty()
                })
            cell.accessoryView = searchButton
            let lb = UILabel(frame: CGRectMake(0, 50, self.view.bounds.width, 1))
            lb.backgroundColor = defaultBackgroundGrayColor
            cell.contentView.addSubview(lb)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.flags.count == 1 {
            self.flags.replaceObjectAtIndex(0 , withObject: !(self.flags.objectAtIndex(0) as! Bool))
        }else {
            for index in 0 ..< self.flags.count {
                if index == indexPath.row {
                    self.flags.replaceObjectAtIndex(index, withObject: true)
                }else{
                    self.flags.replaceObjectAtIndex(index, withObject: false)
                }
            }
            
        }
        self.myTableView.reloadData()
        let fl = self.flags[indexPath.row] as! Bool
        if fl {
            let dict = dataS[indexPath.row] as! NSMutableDictionary
            self.dataFeathc(dict)
        }
        
    }
    //MARK:- private method
    func dataFeathc(dict:NSMutableDictionary){
        let arr = dict.allValues[0] as? NSMutableArray
        let ip = arr![0] as! String
        SocketManagerTool.shareInstance().connectSocket(ip)
        g_ip = ip
        if arr!.count>=2 {
            let tempFlag = (arr![1] as! String).stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            DBManager.shareInstance().updateIp("T_Device" + tempFlag, name2: "T_DeviceDouble" + tempFlag,name3: "T_Scene" + tempFlag)
        }
        
//        self.test()
        self.fetchList(ip)
    }
    func paraterData(data:NSData){
        var ip:String = ""
        var macAddress:String = ""
        var version:String = ""
        var byteArray:[UInt8] = [UInt8]()
        let dict:NSMutableDictionary = NSMutableDictionary()
        let detail:NSMutableArray = []
        
        for i in 0..<data.length {
            var temp:UInt8 = 0
            data.getBytes(&temp, range: NSRange(location: i,length:1 ))
            let str = String(temp)
            if i>=5 && i <= 8 {
                if i == 5{
                    ip = ip + str
                }else{
                    ip = ip + "." + str
                }
                if i==8 {
                    var tag = false
                    for temp in self.dataS {
                        let tempD = temp as! NSDictionary
                        let arr = tempD.allValues
                        let arrValue = arr[0] as! NSArray
                        let ipStr = arrValue[0] as! NSString
                        if ipStr == ip {
                            tag = true
                        }
                    }
                    if tag {
                        return
                    }else{
                        detail.addObject(ip)
                    }
                }
                
            }
            if i>=9 && i<=14 {
                if i==9{
                    macAddress = macAddress + String(temp,radix:16)
                }else{
                     macAddress = macAddress + ":" + String(temp,radix:16)
                }
               
                if i==14 {
                    detail.addObject(macAddress)
                }
            }
            if i>=15&&i<=18 {
                version = version + str
                if i==18 {
                    detail.addObject(version)
                }
            }
            if i>=19&&i<=82 {
                byteArray.append(temp)
            }
        }
        let tempName = NSString(bytes: byteArray, length: 65, encoding: 0)
        if tempName != nil {
            dict.setValue(detail, forKey: tempName as! String)
            self.dataS.addObject(dict)
            if detail.count>=2 {
                let tempFlag = (detail[1] as! String).stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                DBManager.shareInstance().createTable("T_Device" + tempFlag)
                DBManager.shareInstance().createTableDoubleLight("T_DeviceDouble" + tempFlag)
                DBManager.shareInstance().createTableOfScene("T_Scene" + tempFlag)
                self.flags.addObject(false)
                self.flag = false
                self.myTableView.reloadData()
            }
        }

    }
    
    func  test(){
        
        let d :NSDictionary = [
            "command": 30,
            "Device Information": [
                [
                    "dev_addr": 0,
                    "dev_type": 1,
                    "work_status": 31,
                    "dev_name": "总控设备",
                    "dev_status": 1,
                    "dev_area": 0
                ],
                [
                    "dev_addr": 13014,
                    "dev_type": 2,
                    "work_status": 110,
                    "dev_name": "六场景",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 32881,
                    "dev_type": 3,
                    "work_status": 0,
                    "dev_name": "单火路调光",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 41749,
                    "dev_type": 6,
                    "work_status": 42,
                    "dev_name": "6回路开关",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 41749,
                    "dev_type": 6,
                    "work_status": 42,
                    "dev_name": "6回路开关",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 13358,
                    "dev_type": 5,
                    "work_status": 3,
                    "dev_name": "3回路开关",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 673,
                    "dev_type": 7,
                    "work_status": 17,
                    "dev_name": "窗帘控制",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 25988,
                    "dev_type": 4,
                    "work_status": 230,
                    "dev_name": "双回路调光",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 18279,
                    "dev_type": 11,
                    "work_status": 10,
                    "dev_name": "干接点",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
    
                [
                    "dev_addr": 182700,
                    "dev_type": 12,
                    "work_status": 0,
                    "dev_name": "空调",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                
                [
                    "dev_addr": 38585,
                    "dev_type": 3,
                    "work_status": 0,
                    "dev_name": "单水路调光",
                    "dev_status": 1,
                    "dev_area": 0
                ]
            ]
        ]
        
        let devices = d.objectForKey("Device Information") as! NSArray
      
        if (devices.count != 0) {

            let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
            let descs2 = NSArray(objects: typeDesc)
            let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
//            DBManager.shareInstance().deleteAll()
            
            for tempDict in array {
                self.exeDB(tempDict as! NSDictionary)
            }
            
        }
        
    }
    func  test1(){
        
        let d :NSDictionary = [
                "command": 30,
                "Device Information": [
                [
                "dev_addr": 0,
                "dev_type": 1,
                "work_status": 0,
                "dev_name": "总控设备",
                "dev_status": 1,
                "dev_area": 0
                ],
                [
                "dev_addr": 1772,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 47893
                ],
                [
                "dev_addr": 62234,
                "dev_type": 2,
                "work_status": 0,
                "dev_name": "六场景",
                "dev_status": 1,
                "dev_area": 62234
                ],
                [
                "dev_addr": 41729,
                "dev_type": 2,
                "work_status": 0,
                "dev_name": "六场景",
                "dev_status": 1,
                "dev_area": 41729
                ],
                [
                "dev_addr": 40807,
                "dev_type": 2,
                "work_status": 97,
                "dev_name": "研发办公室",
                "dev_status": 1,
                "dev_area": 40807
                ],
                [
                "dev_addr": 47893,
                "dev_type": 2,
                "work_status": 0,
                "dev_name": "六场景",
                "dev_status": 1,
                "dev_area": 47893
                ],
                [
                "dev_addr": 20297,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 0
                ],
                [
                "dev_addr": 52095,
                "dev_type": 2,
                "work_status": 0,
                "dev_name": "六场景",
                "dev_status": 1,
                "dev_area": 52095
                ],
                [
                "dev_addr": 36921,
                "dev_type": 2,
                "work_status": 0,
                "dev_name": "六场景",
                "dev_status": 1,
                "dev_area": 36921
                ],
                [
                "dev_addr": 36545,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 47893
                ],
                [
                "dev_addr": 43471,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 41729
                ],
                [
                "dev_addr": 24281,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 24318
                ],
                [
                "dev_addr": 39569,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 36921
                ],
                [
                "dev_addr": 65223,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 40807
                ],
                [
                "dev_addr": 62287,
                "dev_type": 3,
                "work_status": 0,
                "dev_name": "单回路调光",
                "dev_status": 1,
                "dev_area": 36921
                ]
                    ]
            ]
        
        let devices = d.objectForKey("Device Information") as! NSArray
        
        if (devices.count != 0) {
            
            let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
            let descs2 = NSArray(objects: typeDesc)
            let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
//            DBManager.shareInstance().deleteAll()
            
            for tempDict in array {
                self.exeDB(tempDict as! NSDictionary)
            }
            
        }
        
    }

    func exeDB(tempDic:NSDictionary){
        var dev:Device? = nil
        let addr = tempDic["dev_addr"] as! Int
        let dev_type = tempDic["dev_type"] as! Int
        let work_status = tempDic["work_status"] as! Int
 
            let work_status1 = DBManager.shareInstance().selectWorkStatus(String(addr), flag: 0)
            let work_status2 = DBManager.shareInstance().selectWorkStatus(String(addr), flag: 1)
        let name = tempDic["dev_name"] as! String
        let dev_area = tempDic["dev_area"] as! Int
        let dev_status = tempDic["dev_status"] as! Int
        let belong_area = tempDic["dev_area"] as! Int
        let is_favourited = DBManager.shareInstance().selectWorkFav(String(addr), flag: 0)
        var image:NSData = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
        if (dev_type == 1) {//总控
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Room_MasterRoom_icon1" )!, 1)!
            }else{
                image = tp
            }
        }else if(dev_type == 2){//六情景
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            }else{
                image = tp
            }
        }else if(dev_type == 3){//单回路调光
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
            }else{
                image = tp
            }
            
        }else if(dev_type == 6){//6回路开关
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_6ch-roads_icon" )!, 1)!
            }else{
                image = tp
            }
            
        }else if(dev_type == 5){//3回路开关
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_3ch-roads_icon" )!, 1)!
            }else{
                image = tp
            }
            
        }
        else if(dev_type == 7){//窗帘控制
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Curtains_icon" )!, 1)!
            }else{
                image = tp
            }
            
        }else if(dev_type == 4){//双回路调光
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
            }else{
                image = tp
            }
            
            
        }
        else if(dev_type == 8){//单回路调光控制端(旧版)
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
            }else{
                image = tp
            }
            
            
        }else if(dev_type == 9){//双回路调光控制端(旧版)
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
            }else{
                image = tp
            }
            
            
        }else if(dev_type == 10){//三/六回路开关控制端
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_3or6ch-roads_icon" )!, 1)!
            }else{
                image = tp
            }
            
            
        }else if(dev_type == 11){//干接点
            let tp = DBManager.shareInstance().selectWorkImage(String(addr))
            if tp.length == 0 {
                image = UIImageJPEGRepresentation(UIImage(named:"Manage_3or6ch-roads_icon" )!, 1)!
            }else{
                image = tp
            }
            
            
        }else if(dev_type == 12){//空调
//            image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            
        }else if(dev_type == 13){//地暖
//            image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            
        }else if(dev_type == 14){//新风
//            image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            
        }
        dev = Device(address: String(addr), dev_type: dev_type, work_status:work_status,work_status1:work_status1,work_status2:work_status2, dev_name: name, dev_status: dev_status, dev_area: String(dev_area), belong_area: String(belong_area), is_favourited: is_favourited, icon_url: image)
        
        if dev != nil {
            if DBManager.shareInstance().isDataExist((dev?.address!)!){
                DBManager.shareInstance().update(dev!);
            }else{
                DBManager.shareInstance().add(dev!);
            }
            
            if (dev_type == 4 || dev_type == 9){
                DBManager.shareInstance().addLight(dev!);
            }
       
        }
        
    }
    func fetchList(ip:String){
        let dict = ["command": 30]
        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
            QNTool.hiddenActivityView()
            if result is NSDictionary {
                let d = result as! NSDictionary
                let devices = d.objectForKey("Device Information") as! NSArray
                if (devices.count != 0) {
//                    DBManager.shareInstance().deleteAll()
                    let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
                    let descs2 = NSArray(objects: typeDesc)
                    let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
                    for tempDict in array {
                        self.exeDB(tempDict as! NSDictionary)
                    }
//                    self.myTableView.reloadData()
                }
            }
        })
    }


    func fectchData() {
//        let dataArr:[UInt8] = [254, 84, 51, 0, 0, 192, 168, 1, 101, 0, 26, 182, 2, 192, 143, 0, 0, 0, 0, 84, 45, 84, 111, 117, 99, 104, 105, 110, 103, 32, 71, 97, 116, 101, 119, 97, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217]
//        let tempData:NSData = NSData(bytes: dataArr, length: 84)
//        self.paraterData(tempData)
////
//        let dataArr1:[UInt8] = [254, 84, 51, 0, 0, 192, 168, 1, 101, 0, 26, 182, 2, 192, 143, 0, 0, 0, 0, 84, 45, 84, 111, 117, 99, 104, 105, 110, 103, 32, 71, 97, 116, 101, 119, 97, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217]
//        let tempData1:NSData = NSData(bytes: dataArr1, length: 84)
//        self.paraterData(tempData1)
//
//
////
//        let dataArr2:[UInt8] = [254, 84, 51, 0, 0, 192, 168, 1, 100, 0, 27, 188, 2, 192, 144, 0, 0, 0, 0, 85, 40, 84, 112, 117, 99, 104, 105, 111, 103, 32, 71, 97, 116, 101, 119, 97, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217]
//        let tempData2:NSData = NSData(bytes: dataArr2, length: 84)
//        self.paraterData(tempData2)
        
        //UDP 广播,发送广播
        let bytes:[UInt8] = [0xff,0x04,0x33,0xca]
        let data = NSData(bytes: bytes, length: 4)
        
        self.outSocket.send(data, complete: { (result) in
            if result is NSData {
                self.paraterData(result as! NSData)
            }
            self.tableViewController.refreshControl?.endRefreshing()
        })
        let globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC))
        dispatch_after(time, globalQueue) { () -> Void in
            self.flag = false
            self.myTableView.reloadData()
            self.tableViewController.refreshControl?.endRefreshing()
        }
    }
}
