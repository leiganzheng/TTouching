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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "查找网关"
        //列表创建
        self.tableViewController = UITableViewController(nibName: nil, bundle: nil)
        self.tableViewController.refreshControl = UIRefreshControl()
        self.tableViewController.refreshControl?.rac_signalForControlEvents(UIControlEvents.ValueChanged).subscribeNext({ [weak self](input) -> Void in
            
            })
        self.myTableView.frame = CGRectMake(0, 30, self.view.bounds.width, self.view.bounds.height - 36)
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.myTableView.backgroundColor = defaultBackgroundGrayColor
        self.view.addSubview(self.myTableView!)
        self.fectchData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
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
}
