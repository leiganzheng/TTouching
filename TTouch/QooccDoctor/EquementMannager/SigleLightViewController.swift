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
    var device:Device?
    var data:NSMutableArray!
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
        return 100
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.data.count
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
        let title = DBManager.shareInstance().selectData((d?.dev_area)!) == "" ? NSLocalizedString("选择区域", tableName: "Localization",comment:"jj") :  DBManager.shareInstance().selectData((d?.dev_area)!)
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
                    let save_dev = [["dev_addr": (Int(d!.address!))!,"dev_type": (Int(d!.dev_type!)),"dev_name": QNTool.UTF8TOGB2312(textField.text!)]]
                    QNTool.modifyEqument(save_dev,name:textField.text!)
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
        
        cell.cmdData.addTarget(self, action: #selector(SigleLightViewController.sliderValueChanged(_:)), forControlEvents: .ValueChanged)
       cell.cmdData.value = Float((d?.work_status)!)
        cell.valueLB.text = "\((d?.work_status)!)%"
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
        let tempCell = slider.superview?.superview as! SingleTableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
         tempCell.valueLB.text = "\(Int(slider.value))%"
        QNTool.openLight(d, value: Int(slider.value))
    

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
            if element.dev_type == 3 || element.dev_type == 8{
                self.data.addObject(element)
            }
        }
        self.myCustomTableView.reloadData()
        
    }
    
    
   
}
