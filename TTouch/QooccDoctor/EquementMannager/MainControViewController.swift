//
//  MainControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MainControViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    var sockertManger:SocketManagerTool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
        self.sockertManger = SocketManagerTool()
        self.fetchData()
        
//        let vc = UdpSocketController.shareInstance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: MainTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? MainTableViewCell
        if cell == nil{
            cell = MainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        let d = self.data[indexPath.row] as? Device
        let btn = cell.name
        btn.setTitle(d?.dev_name!, forState: .Normal)
//        17:开启总控情景一; 18:开启总控情景二; 19:开启总控情景三; 20:开启总控情景四; 21:开启总控情景五;31:所有设备 OFF。
//        22:保存当前情景为总控情景一; 23:保存当前情景为总控情景二; 24:保存当前情景为总控情景三; 25:保存当前情景为总控情景四; 26:保存当前情景为总控情景五;
        //开启总控情景一
        cell.p1Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":17]
            self.sockertManger.sendMsg(dict)

            return RACSignal.empty()
        })
        
        //开启总控情景二
        cell.p2Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":18]
            self.sockertManger.sendMsg(dict)
            
            return RACSignal.empty()
        })
        //开启总控情景三
        cell.p3Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":19]
            self.sockertManger.sendMsg(dict)
            
            return RACSignal.empty()
        })
        //开启总控情景四
        cell.p4Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":20]
            self.sockertManger.sendMsg(dict)
            
            return RACSignal.empty()
        })
        //开启总控情景五
        cell.p5Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":21]
            self.sockertManger.sendMsg(dict)
            
            return RACSignal.empty()
        })
        //关闭所有设备
        cell.p6Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 0,"dev_type":1,"work_status":31]
            self.sockertManger.sendMsg(dict)
            
            return RACSignal.empty()
        })


        
        let gesture = UILongPressGestureRecognizer()
        btn.addGestureRecognizer(gesture)
        gesture.rac_gestureSignal().subscribeNext { (obj) in
            let title = "修改名字"
            let cancelButtonTitle = "取消"
            let otherButtonTitle = "确定"
            
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
            
            
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { (action) in
                
            }
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { (action) in
                let textField = (alertController.textFields?.first)! as UITextField
                btn.setTitle(textField.text, forState: .Normal)
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            self.presentViewController(alertController, animated: true) {
                
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myCustomTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK:- private method
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type == 1 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
    }
}