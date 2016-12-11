//
//  SigleLightViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Darwin.C

class SigleLightViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    var sockertManger:SocketManagerTool!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "单回路调光"
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
        return 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: SingleTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? SingleTableViewCell
        if cell == nil {
            cell = SingleTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
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
                let save_dev = [["dev_addr": 25678,"dev_type": 3,"dev_name": "单回路调光"]]
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
        
        btn1.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            
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
        
        cell.cmdData.addTarget(self, action: #selector(SigleLightViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        return cell
    }
    func sliderValueChanged(slider: UISlider) {
       /*"dev_addr": 38585,
        "dev_type": 3,
        "work_status": 0,
        "dev_name": "单回路调光",
        "dev_status": 1,
        "dev_area": 0*/
        //单回路调光控制端 work_status操作码范围是 0 ~ 99,分别表示调光百分比; 0:关闭回路调光;99:最大调光亮度。
//        let data = slider.value
        var dict:NSDictionary = [:]
        let command = 36
        let dev_addr = 38585
        let dev_type = 3
        var msg = ""
        if slider.value == 0 {
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":223]
            msg = "关闭调光"
        }else if(slider.value>0&&slider.value<24){//调光一档
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":209]
            msg = "关闭调光"

        }else if(slider.value>=25&&slider.value<50){//调光二档
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":210]
            msg = "关闭调光"
            
        }
        else if(slider.value>=50&&slider.value<75){//调光三档
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":211]
            msg = "关闭调光"
            
        }
        else if(slider.value>=75&&slider.value<99){//调光四档
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":212]
            msg = "关闭调光"
            
        }else if(slider.value == 99){
            dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":222]
            msg = "关闭调光"
            
        }
        self.sockertManger.sendMsg(dict, completion: { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("work_status") as! NSNumber
            if (status == 18){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
            }
        })
   

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
                if element.dev_type == 3 {
                    self.data.addObject(element)
                }
                
            }

            self.myCustomTableView.reloadData()
        
    }
    
    
   
}
