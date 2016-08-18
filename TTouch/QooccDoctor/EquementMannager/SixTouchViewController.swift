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
            self.sockertManger = SocketManagerTool()
            
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
        func sliderValueChanged(switchBtn: UISwitch) {
            //三回路开关控制端
            //        let data = slider.value
            
            let dict = ["command": 36,"dev_addr" : 62252,"dev_type":5,"work_status":2]
            sockertManger.sendMsg(dict)
            sockertManger.SBlock =  {(vc) -> Void in
                print("success")
            }
            
            
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
