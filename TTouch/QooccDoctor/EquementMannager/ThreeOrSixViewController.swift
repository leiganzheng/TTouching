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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "3/6回路调光"
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
        if self.flag {
             return 284
        }
        return 154
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: ThressOrSixTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? ThressOrSixTableViewCell
        if cell == nil {
            cell = ThressOrSixTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
         cell.selectionStyle = UITableViewCellSelectionStyle.None
        let d = self.data[indexPath.row] as? Device
        let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
        cell.isopen.backgroundColor = color
        let title = DBManager.shareInstance().selectData((d?.dev_area)!) == "" ? NSLocalizedString("选择区域", tableName: "Localization",comment:"jj") :  DBManager.shareInstance().selectData((d?.dev_area)!)
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
        let tempT = d?.dev_name
        cell.name.setTitle(tempT, forState: .Normal)
//        cell.name.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
//            
//            let vc = HuiLuSelectViewController()
//            let popover = FPPopoverController(viewController: vc)
//            vc.bock = {(title) -> Void in
//                //修改数据库
//                self.flag = title as! String ==  "六回路" ?  true :  false
//                cell.name.setTitle(title as? String, forState: .Normal)
//                self.fetchData()
////                self.myCustomTableView.reloadData()
//                popover.dismissPopoverAnimated(true)
//            }
//            
//            popover.contentSize = CGSizeMake(150, 200)
//            popover.tint = FPPopoverWhiteTint
//            popover.border = false
//            popover.arrowDirection = FPPopoverArrowDirectionAny
//            popover.presentPopoverFromView(cell.name)
//            return RACSignal.empty()
//            
//        })
        let gesture = UILongPressGestureRecognizer()
        cell.name.addGestureRecognizer(gesture)
        gesture.rac_gestureSignal().subscribeNext { (obj) in
            let title = NSLocalizedString("修改名字", tableName: "Localization",comment:"jj")
            let cancelButtonTitle = NSLocalizedString("取消", tableName: "Localization",comment:"jj")
            let otherButtonTitle = NSLocalizedString("确定", tableName: "Localization",comment:"jj")
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { (action) in
            }
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { (action) in
                let textField = (alertController.textFields?.first)! as UITextField
                cell.name.setTitle(textField.text, forState: .Normal)
                
                if textField.text != nil {
                    let save_dev = [["dev_addr": (Int(d!.address!))!,"dev_type": (Int(d!.dev_type!)),"dev_name": QNTool.UTF8TOGB2312(textField.text!)]]
                    QNTool.modifyEqument(save_dev,name:textField.text!)
                    DBManager.shareInstance().updateName(textField.text!, type: (d?.address)!)
                    self.fetchData()
                }
                
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.text = d?.dev_name
            }
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            self.presentViewController(alertController, animated: true) {
                
            }
        }


         cell.switch1.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch1.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(14, 1)) == "1"
        
         cell.switch2.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch2.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(13, 1)) == "1"
         cell.switch3.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch3.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(12, 1)) == "1"
         cell.switch4.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch4.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(11, 1)) == "1"
         cell.switch5.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch5.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(10, 1)) == "1"
         cell.switch6.addTarget(self, action: #selector(ThreeOrSixViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
        cell.switch6.on = QNTool.xnStringAndBinaryDigit((d?.work_status)!).substringWithRange(NSMakeRange(9, 1)) == "1"
        
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "1") != nil {
            cell.r1.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "1") as? String, forState: .Normal)
        }
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "2") != nil {
            cell.r2.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "2") as? String, forState: .Normal)
        }
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "3") != nil {
            cell.r3.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "3") as? String, forState: .Normal)
        }
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "4") != nil {
            cell.r4.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "4") as? String, forState: .Normal)
        }
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "5") != nil {
            cell.r5.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "5") as? String, forState: .Normal)
        }
        if getObjectFromUserDefaults((d?.address)! + g_ip! + "6") != nil {
            cell.r6.setTitle(getObjectFromUserDefaults((d?.address)! + g_ip! + "6") as? String, forState: .Normal)
        }

        
        QNTool.showM(d!, num: "1", vc: self, touchView: cell.r1)
        QNTool.showM(d!, num: "2", vc: self, touchView: cell.r2)
        QNTool.showM(d!, num: "3", vc: self, touchView: cell.r3)
        QNTool.showM(d!, num: "4", vc: self, touchView: cell.r4)
        QNTool.showM(d!, num: "5", vc: self, touchView: cell.r5)
        QNTool.showM(d!, num: "6", vc: self, touchView: cell.r6)
        
        
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
            if self.flag {
                if element.dev_type == 6 {
                    self.data.addObject(element)
                }
                
                print("Device:\(element.address!)", terminator: "");
            }else{
                if element.dev_type == 5 {
                    self.data.addObject(element)
                }
                
                print("Device:\(element.address!)", terminator: "");
            }
            
        }
        self.myCustomTableView.reloadData()
        
    }
    func sliderValueChanged(switchBtn: UISwitch) {
        let tempCell = switchBtn.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        
        let command = 36
        let dev_addr = Int(d.address!)
        let dev_type:Int = d.dev_type!
        var dict:NSDictionary = [:]
        var value = QNTool.xnStringAndBinaryDigit(Int(d.work_status!))
        //三回路开关控制端
        if switchBtn.tag == 100  {
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(14, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(14, 1), withString: "0")
            }
        }else if(switchBtn.tag == 101){
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(13, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(13, 1), withString: "0")
            }
        }else if(switchBtn.tag == 102){
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(12, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(12, 1), withString: "0")
            }
        }else if(switchBtn.tag == 103){
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(11, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(11, 1), withString: "0")
            }
        }else if(switchBtn.tag == 104){
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(10, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(10, 1), withString: "0")
            }
        }else if(switchBtn.tag == 105){
            if switchBtn.on {
                value = value.stringByReplacingCharactersInRange(NSMakeRange(9, 1), withString: "1")
            }else{
                value = value.stringByReplacingCharactersInRange(NSMakeRange(9, 1), withString: "0")
            }
        }
         var work_status = 0
        if self.flag {//
            work_status = QNTool.binary2dec(value as String)
        }else{
            work_status = QNTool.binary2dec(value as String)
        }
        
        DBManager.shareInstance().updateStatus(work_status, type: d.address!)
        dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":work_status ]
        self.sockertManger.sendMsg(dict, completion: { (result) in
            DBManager.shareInstance().updateStatus(work_status, type: d.address!)
             self.fetchData()

        })
    }
    


}
