//
//  SixTouchViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/8/17.
//  Copyright © 2016年 Private. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SixTouchViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
        
        @IBOutlet weak var myCustomTableView: UITableView!
        var data: NSMutableArray!
        var sockertManger:SocketManagerTool!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = "六触点"
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
            return 280
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.data.count
        }
        
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            if self.data.count==0 {
                let cellIdentifier = "Cell"
                var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
                if cell == nil {
                    cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                }
                tableView.separatorStyle = .None
                let lb = UILabel(frame: CGRectMake(screenWidth/2-100,0,200,72))
                lb.text = "暂无数据"
                lb.textAlignment = .Center
                cell.contentView.addSubview(lb)
                return cell
            }else {
            let cellId = "cell"
            var cell: SixTouchTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? SixTouchTableViewCell
            if cell == nil {
                cell = SixTouchTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
            }
            let d = self.data[indexPath.row] as? Device
            let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
            cell.isopen.backgroundColor = color
            let title = d?.dev_area == "" ? "选择区域" :  d?.dev_area
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
                
                return cell
            }
        }
        
        func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.myCustomTableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        //MARK:- private method
        func sliderValueChanged(switchBtn: UISwitch) {

            let tempCell = switchBtn.superview?.superview as! SixTouchTableViewCell
            let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
            let d = self.data[(indexPath?.row)!] as! Device
            
            let command = 36
            let dev_addr = Int(d.address!)
            let dev_type:Int = d.dev_type!
            var dict:NSDictionary = [:]
            var value = QNTool.xnStringAndBinaryDigit(Int(d.work_status!))
            //三回路开关控制端
            if switchBtn  == tempCell.switch1  {
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(14, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(14, 1), withString: "0")
                }
            }else if(switchBtn == tempCell.switch2){
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(13, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(13, 1), withString: "0")
                }
            }else if(switchBtn == tempCell.switch3){
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(12, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(12, 1), withString: "0")
                }
            }else if(switchBtn == tempCell.switch4){
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(11, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(11, 1), withString: "0")
                }
            }else if(switchBtn == tempCell.switch5){
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(10, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(10, 1), withString: "0")
                }
            }else if(switchBtn == tempCell.switch6){
                if switchBtn.on {
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(9, 1), withString: "1")
                }else{
                    value = value.stringByReplacingCharactersInRange(NSMakeRange(9, 1), withString: "0")
                }
            }
     
               let work_status = QNTool.binary2dec(value as String)
            
                    DBManager.shareInstance().updateStatus(work_status, type: d.address!)
                    self.fetchData()
            dict = ["command": command,"dev_addr" : dev_addr!,"dev_type":dev_type,"work_status":work_status ]
            self.sockertManger.sendMsg(dict, completion: { (result) in
                DBManager.shareInstance().updateStatus(work_status, type: d.address!)
                self.fetchData()
                
            })
        }
        
        func fetchData(){
            self.data = NSMutableArray()
            self.data.removeAllObjects()
            //查
            let arr:Array<Device> = DBManager.shareInstance().selectDatas()
            
            for (_, element): (Int, Device) in arr.enumerate(){
                if element.dev_type == 11 {
                    self.data.addObject(element)
                }
                
                print("Device:\(element.address!)", terminator: "");
            }
            self.myCustomTableView.reloadData()
    }
}

