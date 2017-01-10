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
        self.title = "查找网关"
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
//        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ [weak self](input) -> Void in
//            self?.fectchData()
//            })
        self.tableViewController.refreshControl?.addTarget(self, action: #selector(GateWayListViewController.pullData), forControlEvents: UIControlEvents.ValueChanged)
//        self.tableViewController.refreshControl?.attributedTitle = NSAttributedString(string: "下拉刷新数据")
        self.myTableView.frame = CGRectMake(0, 30, self.view.bounds.width, self.view.bounds.height - 48)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth]
        self.myTableView.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
        
        searchButton = UIButton(frame: CGRectMake(10, screenHeight - 160, screenWidth-20, 48))
        searchButton.setTitle("选择", forState: UIControlState.Normal)
        searchButton.backgroundColor = appThemeColor
        QNTool.configViewLayer(searchButton)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            for temp in self.flags {
                if (temp as! Bool) == true {
                    let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
                    QNTool.enterRootViewController(vc, animated: true)
                }else{
                    QNTool.showPromptView("请选择网关")
                    break
                }
            }
            return RACSignal.empty()
        })
        self.view.addSubview(searchButton)
        
        
        //局域网内搜索网关
        outSocket = OutSocket()
        self.tableViewController.refreshControl?.beginRefreshing()
        DBManager.shareInstance().createTable("T_Device")
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
            lb.text = "暂无数据,下拉重试"
            lb.textColor = UIColor.lightGrayColor()
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else{

        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.contentView.backgroundColor = UIColor.whiteColor()
            let dict = dataS[indexPath.row] as! NSMutableDictionary
            cell.textLabel?.text = dict.allKeys[0] as? String
            
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
    }
    //MARK:- private method
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
                    detail.addObject(ip)
                }
                
            }
            if i>=9 && i<=14 {
                macAddress = macAddress + str
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
            DBManager.shareInstance().ip = ip
            self.dataS.addObject(dict)
            self.flags.addObject(false)
            self.flag = false
            self.myTableView.reloadData()
//                    self.test()
            self.fetchList()
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
                    "work_status": 111,
                    "dev_name": "六场景",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 32881,
                    "dev_type": 3,
                    "work_status": 0,
                    "dev_name": "单回路调光",
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
                    "work_status": 2,
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
                    "work_status": 238,
                    "dev_name": "双回路调光",
                    "dev_status": 1,
                    "dev_area": 13014
                ],
                [
                    "dev_addr": 38585,
                    "dev_type": 3,
                    "work_status": 0,
                    "dev_name": "单回路调光",
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
            DBManager.shareInstance().deleteAll()
            
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
        let work_status1 = Int(200)
        let name = tempDic["dev_name"] as! String
        let dev_area = tempDic["dev_area"] as! Int
        let dev_status = tempDic["dev_status"] as! Int
        let belong_area = tempDic["dev_area"] as! Int
        let is_favourited = 1
        var image:NSData = NSData()
        if (dev_type == 1) {//总控
            image = UIImageJPEGRepresentation(UIImage(named:"Room_MasterRoom_icon1" )!, 1)!
            
        }else if(dev_type == 2){//六情景
            image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            
        }else if(dev_type == 3){//单回路调光
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
            
        }else if(dev_type == 6){//6回路开关
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_6ch-roads_icon" )!, 1)!
            
        }else if(dev_type == 5){//3回路开关
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_3ch-roads_icon" )!, 1)!
            
        }
        else if(dev_type == 7){//窗帘控制
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Curtains_icon" )!, 1)!
            
        }else if(dev_type == 4){//双回路调光
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
            
        }
        else if(dev_type == 8){//单回路调光控制端(旧版)
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
            
        }else if(dev_type == 9){//双回路调光控制端(旧版)
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
            
        }else if(dev_type == 10){//三/六回路开关控制端
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_3or6ch-roads_icon" )!, 1)!
            
        }else if(dev_type == 11){//干接点
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if(dev_type == 12){//空调
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if(dev_type == 13){//地暖
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if(dev_type == 14){//新风
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }
        dev = Device(address: String(addr), dev_type: dev_type, work_status:work_status,work_status1:work_status1, dev_name: name, dev_status: dev_status, dev_area: String(dev_area), belong_area: String(belong_area), is_favourited: is_favourited, icon_url: image)
        
        if dev != nil {
            //创建表
            DBManager.shareInstance().add(dev!);
       
        }
        
    }
    func fetchList(){
        let dict = ["command": 30]
        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
            QNTool.hiddenActivityView()
//            print(dict)
            if result is NSDictionary {
                let d = result as! NSDictionary
                let devices = d.objectForKey("Device Information") as! NSArray
                if (devices.count != 0) {
                    DBManager.shareInstance().deleteAll()
                    let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
                    let descs2 = NSArray(objects: typeDesc)
                    let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
                    for tempDict in array {
                        self.exeDB(tempDict as! NSDictionary)
                    }
                    self.myTableView.reloadData()
                }
            }
        })
    }


    func fectchData() {
//        let dataArr:[UInt8] = [254, 84, 51, 0, 0, 192, 168, 1, 100, 0, 26, 182, 2, 192, 143, 0, 0, 0, 0, 84, 45, 84, 111, 117, 99, 104, 105, 110, 103, 32, 71, 97, 116, 101, 119, 97, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217]
//        let tempData:NSData = NSData(bytes: dataArr, length: 84)
//        self.paraterData(tempData)
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
