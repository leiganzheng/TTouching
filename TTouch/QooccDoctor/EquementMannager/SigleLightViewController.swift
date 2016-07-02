//
//  SigleLightViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SigleLightViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
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
        var cell: UITableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            //            cell.accessoryType = .DisclosureIndicator
        }
        let d = self.data[indexPath.row] as? Device
        
        let btn1 = cell.contentView.viewWithTag(101) as! UIButton
        
        btn1.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
            self?.selectedPattern(btn1)
            return RACSignal.empty()
            
            })
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
            if element.dev_type == 8 {
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }
    
    func selectedPattern(sender:UIButton) {
        let vc = DemoTableController(style: .Plain)
        let popover = FPPopoverController(viewController: vc)
        popover.contentSize = CGSizeMake(150, 200)
        popover.tint = FPPopoverWhiteTint
        popover.alpha = 0.5
        popover.border = false
        popover.arrowDirection = FPPopoverArrowDirectionAny
        popover.presentPopoverFromView(sender)
        
    }

   
}
