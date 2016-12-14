//
//  DoubleLightViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class DoubleLightViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var device:Device?
    var data:NSMutableArray!
     var flag:String?//0：主界面 1：设备管理 2：左边快捷菜单
    var sockertManger:SocketManagerTool!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "双回路调光"
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
        return 120
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: DoubleTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? DoubleTableViewCell
        if cell == nil {
            cell = DoubleTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        let d = self.data[indexPath.row] as? Device
        let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
        cell.isOpen.backgroundColor = color
        let title = d?.dev_area == "" ? "选择区域" :  DBManager.shareInstance().selectData((d?.dev_area)!)
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
                    let save_dev = [["dev_addr": (d?.address)!,"dev_type": (d?.dev_type)!,"dev_name": textField.text!]]
                    QNTool.modifyEqument(save_dev)
                }

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
        cell.slider1.addTarget(self, action: #selector(SigleLightViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.slider2.addTarget(self, action: #selector(SigleLightViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
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
            if element.dev_type == 4 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }
    func sliderValueChanged(slider: UISlider) {
        //双回路调光控制端 work_status设备操作码,范围是 0 ~ 299,表示调光百分比; 0:同时关闭两回路;99:两回路最大调光亮度; 100:关闭左回路;199:左回路最大调光亮度; 200:关闭右回路;299:右回路最大调光亮度; 例:左回路 60%亮度:160;右回路 70%亮度:270。
        //        let data = slider.value
        let tempCell = slider.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        var dict:NSDictionary = [:]
        let command = 36
        let dev_addr = d.address
        let dev_type = d.dev_type
        var msg = ""
        if dev_type == 4 {
            if slider.tag == 100 {
                slider.minimumValue = 100
                slider.maximumValue = 199
                if slider.value == 100   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":100]
                    msg = "关闭左回路"
                }else if(slider.value>100&&slider.value<199){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 199 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":199]
                    msg = "最大亮度"
                    
                }
                self.sockertManger.sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue >= 0 && status.intValue <= 99){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
            }else if (slider.value == 101){
                slider.minimumValue = 200
                slider.maximumValue = 299
                if slider.value == 200   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":200]
                    msg = "关闭右回路"
                }else if(slider.value>200&&slider.value<299){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 299 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":199]
                    msg = "最大亮度"
                    
                }
                self.sockertManger.sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue >= 0 && status.intValue <= 99){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })
            }
        }else if(dev_type == 9){//老版本
            if slider.tag == 100 {
                slider.minimumValue = 264
                slider.maximumValue = 268
                if slider.value == 264   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":264]
                    msg = "关闭左回路"
                }else if(slider.value>264&&slider.value<268){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 268 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":199]
                    msg = "最大亮度"
                    
                }
                self.sockertManger.sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue > 264 && status.intValue < 268){
                        //停止调光
                         dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":8]
                        self.sockertManger.sendMsg(dict, completion: { (result) in
                           
                        })
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else if (status.intValue > 264 || status.intValue < 268){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }
                    else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })

            }else if (slider.value == 101){
                slider.minimumValue = 384
                slider.maximumValue = 448
                if slider.value == 384   {
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":384]
                    msg = "关闭左回路"
                }else if(slider.value>384&&slider.value<448){//调光
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":Int(slider.value)]
                    msg = "调光中"
                    
                }else if(slider.value == 448 ){
                    dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":448]
                    msg = "最大亮度"
                    
                }
                self.sockertManger.sendMsg(dict, completion: { (result) in
                    let d = result as! NSDictionary
                    let status = d.objectForKey("work_status") as! NSNumber
                    if (status.intValue > 384 && status.intValue < 448){
                        //停止调光
                        dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type!,"work_status":128]
                        self.sockertManger.sendMsg(dict, completion: { (result) in
                            
                        })
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }else if (status.intValue > 384 || status.intValue < 448){
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: msg)
                    }
                    else{
                        QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
                    }
                })

            }
        }
        
    }

    
}
