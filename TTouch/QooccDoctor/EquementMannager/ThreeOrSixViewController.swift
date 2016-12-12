//
//  ThreeOrSixViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ThreeOrSixViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var myCustomTableView: UITableView!
    var device:Device?
    var data:NSMutableArray!
    var sockertManger:SocketManagerTool!
    var flag:Bool = false
    var commandArr:NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "3/6回路调光"
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
        self.sockertManger = SocketManagerTool.shareInstance()
        self.commandArr = [0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000]
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.flag {
             return 280
        }
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: ThressOrSixTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? ThressOrSixTableViewCell
        if cell == nil {
            cell = ThressOrSixTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        let d = self.data[indexPath.row] as? Device
        let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
        cell.isopen.backgroundColor = color
        let title = d?.dev_area == "" ? "选择区域" :  DBManager.shareInstance().selectData((d?.dev_area)!)
        cell.patern.setTitle(title, forState: .Normal)
        let btn1 = cell.patern
        
        btn1.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            
            let vc = PaternViewController()
            let popover = FPPopoverController(viewController: vc)
            vc.bock = {(device) -> Void in
                //修改数据库
                let seltectd = device as? Device
                 cell.patern.setTitle(seltectd?.dev_name, forState: .Normal)
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
        let tempT = self.flag == true ? "六回路" :  "三回路"
        cell.name.setTitle(tempT, forState: .Normal)
        cell.name.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            
            let vc = HuiLuSelectViewController()
            let popover = FPPopoverController(viewController: vc)
            vc.bock = {(title) -> Void in
                //修改数据库
                self.flag = title as! String ==  "六回路" ?  true :  false
                cell.name.setTitle(title as? String, forState: .Normal)
                self.myCustomTableView.reloadData()
                popover.dismissPopoverAnimated(true)
            }
            
            popover.contentSize = CGSizeMake(150, 200)
            popover.tint = FPPopoverWhiteTint
            popover.border = false
            popover.arrowDirection = FPPopoverArrowDirectionAny
            popover.presentPopoverFromView(cell.name)
            return RACSignal.empty()
            
        })

        
         cell.switch1.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
         cell.switch2.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
         cell.switch3.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
         cell.switch4.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
         cell.switch5.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
         cell.switch6.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
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
            if element.dev_type == 5 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }
    func sliderValueChanged(switchBtn: UISwitch) {
        let tempCell = switchBtn.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        
        let command = 36
        let dev_addr = d.address!
        let dev_type = d.dev_type!
        
        //三回路开关控制端
        if switchBtn.tag == 100  {
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(0, withObject: 0b0000000000000001)
            }else{
                self.commandArr?.replaceObjectAtIndex(0, withObject: 0b0000000000000000)
            }
        }else if(switchBtn.tag == 101){
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(1, withObject: 0b0000000000000010)
            }else{
                self.commandArr?.replaceObjectAtIndex(1, withObject: 0b0000000000000000)
            }
        }else if(switchBtn.tag == 102){
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000000100)
            }else{
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000000000)
            }
        }else if(switchBtn.tag == 103){
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000001000)
            }else{
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000000000)
            }
        }else if(switchBtn.tag == 104){
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000010000)
            }else{
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000000000)
            }
        }else if(switchBtn.tag == 105){
            if switchBtn.on {
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000100000)
            }else{
                self.commandArr?.replaceObjectAtIndex(2, withObject: 0b0000000000000000)
            }
        }
         var work_status = 0
        if self.flag {//
            let A = self.commandArr?.objectAtIndex(0) as! Int // 二进制
            let B = self.commandArr?.objectAtIndex(1) as! Int// 二进制
            let C = self.commandArr?.objectAtIndex(2) as! Int// 二进制
            let D = self.commandArr?.objectAtIndex(3) as! Int // 二进制
            let E = self.commandArr?.objectAtIndex(4) as! Int// 二进制
            let F = self.commandArr?.objectAtIndex(5) as! Int// 二进制
            work_status = Int(A|B|C|D|E|F)
        }else{
            let A = self.commandArr?.objectAtIndex(0) as! Int // 二进制
            let B = self.commandArr?.objectAtIndex(1) as! Int// 二进制
            let C = self.commandArr?.objectAtIndex(2) as! Int// 二进制
            work_status = Int(A|B|C)
            print("A|B|C 结果为：\(A|B|C)")
        }
        

        let dict = ["command": command,"dev_addr" : dev_addr,"dev_type":dev_type,"work_status":work_status ]
        self.sockertManger.sendMsg(dict, completion: { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("work_status") as! NSNumber
//            if (status == 97){
//                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "开启情景一！")
//            }else{
//                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "请重试！")
//            }
        })
    }



}
