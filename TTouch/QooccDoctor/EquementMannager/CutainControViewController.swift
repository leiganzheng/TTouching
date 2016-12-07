//
//  CutainControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class CutainControViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    var sockertManger:SocketManagerTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "窗帘"
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
        self.sockertManger = SocketManagerTool()
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 168
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "curtainCell"
        var cell: CurtainTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? CurtainTableViewCell
        if cell == nil {
            cell = CurtainTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        let d = self.data[indexPath.row] as? Device
        let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
        cell.isOpen.backgroundColor = color
        let title = d?.dev_area == "" ? "选择区域" :  d?.dev_area
         cell.partern.setTitle(title, forState: .Normal)
        let btn = cell.name
        btn.setTitle(d?.dev_name!, forState: .Normal)
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
                if textField.text != nil {
                    DBManager.shareInstance().updateName(textField.text!, type: (d?.address)!)
                }
                let save_dev = [["dev_addr": 28411,"dev_type": 7,"dev_name": "窗帘控制端"]]
                QNTool.modifyEqument(save_dev)
                
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            self.presentViewController(alertController, animated: true) {
                
            }

        }
        let btn1 = cell.partern

        btn1.rac_command = RACCommand(signalBlock: {(input) -> RACSignal! in

            let vc = PaternViewController()
            let popover = FPPopoverController(viewController: vc)
            vc.bock = {(device) -> Void in
                //修改数据库
                let seltectd = device as? Device
                 cell.partern.setTitle(seltectd?.dev_name, forState: .Normal)
                DBManager.shareInstance().update((seltectd?.address)!, type: (d?.address)!)
                popover.dismissPopoverAnimated(true)
            }
            
            popover.contentSize = CGSizeMake(150, 200)
            popover.tint = FPPopoverWhiteTint
            popover.border = false
            popover.arrowDirection = FPPopoverArrowDirectionAny
            popover.presentPopoverFromView(btn1)

            return RACSignal.empty()
           
            })
        cell.open1Btn.addTarget(self, action: #selector(CutainControViewController.open1(_:)), forControlEvents: .TouchUpInside)
        cell.stop1Btn.addTarget(self, action: #selector(CutainControViewController.stop1(_:)), forControlEvents: .TouchUpInside)
        cell.close1Btn.addTarget(self, action: #selector(CutainControViewController.close1(_:)), forControlEvents: .TouchUpInside)
        
        cell.open2Btn.addTarget(self, action: #selector(CutainControViewController.open2(_:)), forControlEvents: .TouchUpInside)
        cell.stop2Btn.addTarget(self, action: #selector(CutainControViewController.stop2(_:)), forControlEvents: .TouchUpInside)
        cell.close2Btn.addTarget(self, action: #selector(CutainControViewController.close2(_:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myCustomTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK:- private method
    func open1(sender: UIButton){
        let dict = ["command": 36,"dev_addr" : 60838,"dev_type":7,"work_status":192]
        sockertManger.sendMsg(dict)
        sockertManger.SBlock =  {(vc) -> Void in
            print("success")
        }

    }
    func stop1(sender: UIButton){
        
    }
    func close1(sender: UIButton){
        
    }
    func open2(sender: UIButton){
        
    }
    func stop2(sender: UIButton){
        
    }
    func close2(sender: UIButton){
        
    }
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type == 7 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }


}
