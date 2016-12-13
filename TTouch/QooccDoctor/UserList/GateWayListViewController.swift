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
    var inSocket : InSocket!
    var outSocket : OutSocket!
    var flags:NSMutableArray = []
    var dataS:NSMutableArray = []
    var searchButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "查找网关"
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ [weak self](input) -> Void in
            self?.fectchData()
            })
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
//           self.fectchData()
            
            let vc = (UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController())!
            QNTool.enterRootViewController(vc, animated: true)
            return RACSignal.empty()
            })
        self.view.addSubview(searchButton)
        
        
       self.tableViewController.refreshControl?.beginRefreshing()
        //局域网内搜索网关
        outSocket = OutSocket()
        self.fectchData()
//        self.exeDB()

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
        return dataS.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        let tempName = NSString(bytes: byteArray, length: 65, encoding: 0) as! String
        dict.setValue(detail, forKey: tempName)
        
        DBManager.shareInstance().ip = ip
        self.dataS.addObject(dict);
        self.flags.addObject(true)
        self.myTableView.reloadData()

    }
    func fectchData() {
        let dataArr:[UInt8] = [254, 84, 51, 0, 0, 192, 168, 1, 100, 0, 26, 182, 2, 192, 143, 0, 0, 0, 0, 84, 45, 84, 111, 117, 99, 104, 105, 110, 103, 32, 71, 97, 116, 101, 119, 97, 121, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 217]
        let tempData:NSData = NSData(bytes: dataArr, length: 84)
        self.paraterData(tempData)
        //UDP 广播,发送广播
//        let bytes:[UInt8] = [0xff,0x04,0x33,0xca]
//        let data = NSData(bytes: bytes, length: 4)
//        self.outSocket.send(data, complete: { (result) in
//            self.paraterData(result as! NSData)
//            self.tableViewController.refreshControl?.endRefreshing()
//        })
    }
}
