//
//  AirViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/7/6.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class AirViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "空调"
        self.myCustomTableView.delegate = self
        self.myCustomTableView.dataSource = self
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
        return 332
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
            lb.text = NSLocalizedString("暂无数据,下拉重试", tableName: "Localization",comment:"jj")
            lb.textAlignment = .Center
            cell.contentView.addSubview(lb)
            return cell
        }else {
        let cellId = "cell"
        var cell: AirTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? AirTableViewCell
        if cell == nil {
            cell = AirTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        let d = self.data[indexPath.row] as? Device
        let color = d?.dev_status == 1 ? UIColor(red: 73/255.0, green: 218/255.0, blue: 99/255.0, alpha: 1.0) : UIColor.lightGrayColor()
        cell.isOpen.backgroundColor = color
        let title = d?.dev_area == "" ? NSLocalizedString("选择区域", tableName: "Localization",comment:"jj") :  d?.dev_area
        cell.partern.setTitle(title, forState: .Normal)
        let btn = cell.name
        btn.setTitle(d?.dev_name!, forState: .Normal)
        let gesture = UILongPressGestureRecognizer()
        btn.addGestureRecognizer(gesture)
        gesture.rac_gestureSignal().subscribeNext { (obj) in
            let title = NSLocalizedString("修改名字", tableName: "Localization",comment:"jj")
            let cancelButtonTitle = NSLocalizedString("取消", tableName: "Localization",comment:"jj")
            let otherButtonTitle = NSLocalizedString("确定", tableName: "Localization",comment:"jj")
            
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
            
            
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { (action) in
                
            }
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { (action) in
                let textField = (alertController.textFields?.first)! as UITextField
                btn.setTitle(textField.text, forState: .Normal)
                
                if textField.text != nil {
                    DBManager.shareInstance().updateName(textField.text!, type: (d?.address)!)
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
        
        let btn1 = cell.partern
        
        btn1.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
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
        return cell
        }
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
            if element.dev_type == 12 {
                self.data.addObject(element)
            }
            
        }
        
        self.myCustomTableView.reloadData()
        
    }
    
    
    
}