//
//  SixViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SixViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    var sockertManger:SocketManagerTool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
        self.sockertManger = SocketManagerTool.shareInstance()

        self.fetchData()
        
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
        var cell: SixTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? SixTableViewCell
        if cell == nil{
            cell = SixTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        let d = self.data[indexPath.row] as? Device
        let btn = cell.name
        btn.setTitle(d?.dev_name!, forState: .Normal)
//        97:开启情景一; 98:开启情景二; 99:开启情景三; 100:开启情景四;110:场景组内所有设备 ON 状态; 111:场景组内所有设备 OFF 状态; 102:保存当前情景为情景一; 103:保存当前情景为情景二; 104:保存当前情景为情景三; 105:保存当前情景为情景四。
        let command = 36;
        
        //开启总控情景一
        cell.p1Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
             let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":97]
            self.sockertManger.sendMsg(dict)
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 97){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景一！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
            return RACSignal.empty()
        })
        
        //开启总控情景二
        cell.p2Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
             let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":98]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 98){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景二！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
            return RACSignal.empty()
        })
        //开启总控情景三
        cell.p3Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":99]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 99){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景三！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
            return RACSignal.empty()
        })
        //开启总控情景四
        cell.p4Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":100]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 100){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景四！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
            return RACSignal.empty()
        })
        //场景组内所有设备 ON 状态
        cell.p5Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":110]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 110){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启所有设备！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
            return RACSignal.empty()
        })
        //关闭所有设备
        cell.p6Btn.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let dict = ["command": 36,"dev_addr" : 24606,"dev_type":2,"work_status":111]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                let d = result as! NSDictionary
                let status = d.objectForKey("work_status") as! NSNumber
                if (status == 111){
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "关闭所有设备！")
                }else{
                    QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                }
            })
            
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
                let save_dev = [["dev_addr": 24606,"dev_type": 2,"dev_name": "六情景"]]
                QNTool.modifyEqument(save_dev)
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
            if element.dev_type! == 2{
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }
    
    
}