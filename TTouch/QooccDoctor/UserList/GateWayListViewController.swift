//
//  GateWayListViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/30.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaAsyncSocket

class GateWayListViewController: UIViewController, QNInterceptorProtocol, QNInterceptorNavigationBarShowProtocol,UITableViewDataSource, UITableViewDelegate,AsyncUdpSocketDelegate {
    private var tableViewController: UITableViewController!
    var myTableView: UITableView! {
        return self.tableViewController?.tableView
    }
    var sock:AsyncUdpSocket?
    var flags:NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "查找网关"
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ (input) -> Void in
            
            })
        self.myTableView.frame = CGRectMake(0, 30, self.view.bounds.width, self.view.bounds.height - 48)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth]
        self.myTableView.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
        
        let searchButton:UIButton = UIButton(frame: CGRectMake(10, screenHeight - 160, screenWidth-20, 48))
        searchButton.setTitle("选择", forState: UIControlState.Normal)
        searchButton.backgroundColor = appThemeColor
        QNTool.configViewLayer(searchButton)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
            QNTool.enterRootViewController(vc, animated: true)
            return RACSignal.empty()
            })
        self.view.addSubview(searchButton)
        
        self.flags = [false,true,false]
//        self.fectchData()
        self.exeDB()

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
        return UserTableViewCell.height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        cell.contentView.backgroundColor = UIColor.whiteColor()
        cell.textLabel?.text = "T-Touching Gateway";
        
        let flag = self.flags[indexPath.row] as! Bool
        let icon = (flag==true) ? "pic_hd" : "Menu_Trigger_icon1"
        cell.imageView?.image = UIImage(named: icon)
        
        let searchButton:UIButton = UIButton(type: .Custom)
        searchButton.frame = CGRectMake(0, 5, 40, 30)
        searchButton.setImage(UIImage(named: "Manage_information_icon"), forState: .Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            let vc = GateWayDetailViewController.CreateFromStoryboard("Main") as! UIViewController
            self?.navigationController?.pushViewController(vc, animated: true)
            return RACSignal.empty()
            })
        cell.accessoryView = searchButton
        let lb = UILabel(frame: CGRectMake(0, 50, self.view.bounds.width, 1))
        lb.backgroundColor = defaultBackgroundGrayColor
        cell.contentView.addSubview(lb)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        for index in 0 ..< 3 {
            if index == indexPath.row {
                self.flags.replaceObjectAtIndex(index, withObject: true)
            }else{
                self.flags.replaceObjectAtIndex(index, withObject: false)
            }
        }
        self.myTableView.reloadData()
    }
     //MARK:- private method
    func onUdpSocket(cbsock:AsyncUdpSocket!,didReceiveData data: NSData!){
        print("Recv...")
        print(data)
        cbsock.receiveWithTimeout(10, tag: 0)
    }
    func onUdpSocket(sock: AsyncUdpSocket!, didReceiveData data: NSData!, withTag tag: Int, fromHost host: String!, port: UInt16) -> Bool {
        
        return true
    }
    
    //MARK:- private method
    func fectchData() {
//        QNNetworkTool.scanLocationNet("") { (res) in
//            NSLog(res as! String)
//        }
        if (sock == nil){
            sock = AsyncUdpSocket(delegate: self)
        }
        do{
//            try sock!.bindToPort(33632)
//            try sock!.enableBroadcast(true) // Also tried without this line
            let datastr = "0xFF0x040x330xCA"
            let data = datastr.dataUsingEncoding(NSUTF8StringEncoding)
            sock?.sendData(data, toHost: "255.255.255.255", port: 80, withTimeout: 1, tag: 1)
            sock!.receiveWithTimeout(10,tag: 0)
        } catch {
            print("error")
        }
    }
    func deviceList() {
        
    }
    func exeDB(){

        //总控
        let d = Device(address: "0", dev_type: 1, work_status: 31, dev_name: "总控设备", dev_status: 1, dev_area: "0", belong_area: "所属场景", is_favourited: 0, icon_url: "Manage_ 1ch-Dimmer_icon")
        //六情景
        let sixD = Device(address: "45774", dev_type: 2, work_status: 110, dev_name: "六情景", dev_status: 1, dev_area: "45774", belong_area: "六所属场景", is_favourited: 0, icon_url: "Manage_2ch-Curtains_icon")
        //创建表
        DBManager.shareInstance().createTable("T_Device")
        //增：
        DBManager.shareInstance().add(d);
        DBManager.shareInstance().add(sixD);
        
        //删： 
//        DBManager.shareInstance().deleteData(Device(pid: 1, name: nil, height: nil));
        
        //改：  
//        DBManager.shareInstance().update(Device(pid: 2, name: "清幽", height: 1.80));
        
        //保证线程安全: 增+查
        //      PersonManager.shareInstance().safeaddPerson(Device(pid: 2, name: "清泠", height: 1.80));
        
//        //查
//        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
//        
//        for (index, element): (Int, Device) in arr.enumerate(){
//            print("Device:\(element.address!)", terminator: "");
//        }

    }
}
