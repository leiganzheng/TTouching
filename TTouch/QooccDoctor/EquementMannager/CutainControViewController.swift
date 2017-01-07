//
//  CutainControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class CutainControViewController: UIViewController,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var myCustomTableView: UITableView!
    var device:Device?
    var data:NSMutableArray!
    var sockertManger:SocketManagerTool!
    var commandArr:NSMutableArray?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "窗帘"
        self.view.backgroundColor =  defaultBackgroundColor
        self.myCustomTableView.backgroundColor = UIColor.clearColor()
        self.sockertManger = SocketManagerTool.shareInstance()
        self.commandArr = [0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000,0b0000000000000000]
        self.fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 168
//        return 114
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
        let title = d?.dev_area == "" ? "选择区域" :  DBManager.shareInstance().selectData((d?.dev_area)!)
         cell.partern.setTitle(title, forState: .Normal)
        let btn = cell.name
//        btn.setTitle(d?.dev_name!, forState: .Normal)
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
//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longOpen1(_:)))
//        longGesture.minimumPressDuration = 0.8
//        cell.open1Btn.addGestureRecognizer(longGesture)
        
        let longlongGesture = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longlongOpen1(_:)))
        longlongGesture.minimumPressDuration = 2
        longlongGesture.delegate = self
        cell.open1Btn.addGestureRecognizer(longlongGesture)
        
        cell.stop1Btn.addTarget(self, action: #selector(CutainControViewController.stop1(_:)), forControlEvents: .TouchUpInside)
        cell.close1Btn.addTarget(self, action: #selector(CutainControViewController.close1(_:)), forControlEvents: .TouchUpInside)
//        let longCloseGesture = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longClose1(_:)))
//        longCloseGesture.minimumPressDuration = 0.8
//         cell.close1Btn.addGestureRecognizer(longCloseGesture)
        let longlongCloseGesture = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longlongClose1(_:)))
        longlongCloseGesture.minimumPressDuration = 2
        cell.close1Btn.addGestureRecognizer(longlongCloseGesture)
        
        
        
        cell.open2Btn.addTarget(self, action: #selector(CutainControViewController.open2(_:)), forControlEvents: .TouchUpInside)
        
//        let longGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longOpen2(_:)))
//        longGesture1.minimumPressDuration = 0.8
//        cell.open2Btn.addGestureRecognizer(longGesture1)
        
        let longlongGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longlongOpen2(_:)))
        longlongGesture1.minimumPressDuration = 2
        cell.open2Btn.addGestureRecognizer(longlongGesture1)
        
        cell.stop2Btn.addTarget(self, action: #selector(CutainControViewController.stop2(_:)), forControlEvents: .TouchUpInside)
        cell.close2Btn.addTarget(self, action: #selector(CutainControViewController.close2(_:)), forControlEvents: .TouchUpInside)
        
//        let longCloseGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longClose2(_:)))
//        longCloseGesture1.minimumPressDuration = 0.8
//        cell.close2Btn.addGestureRecognizer(longCloseGesture1)
        let longlongCloseGesture1 = UILongPressGestureRecognizer(target: self, action: #selector(CutainControViewController.longlongClose2(_:)))
        longlongCloseGesture1.minimumPressDuration = 2
        cell.close2Btn.addGestureRecognizer(longlongCloseGesture1)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myCustomTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK:- private method
    func open1(sender: UIButton){

        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 0)

    }
    func longOpen1(sender: UIGestureRecognizer){

        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 1)
    }
    func longlongOpen1(sender: UIGestureRecognizer){
        if sender.state == .Began {
            let tempCell = sender.view!.superview?.superview as! UITableViewCell
            let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
            let d = self.data[(indexPath?.row)!] as! Device
            QNTool.openCutain(d, value: 10)
        }
    }
    func stop1(sender: UIButton){

        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 2)
    }
    func close1(sender: UIButton){

        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 3)
    }
    func longClose1(sender: UIGestureRecognizer){

        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 4)
    }
    func longlongClose1(sender: UIGestureRecognizer){
         if sender.state == .Began {
        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 12)
        }
    }
    func open2(sender: UIButton){
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 5)
    }
    func longOpen2(sender: UIButton){

        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 6)
        
    }
    func longlongOpen2(sender: UIGestureRecognizer){
         if sender.state == .Began {
        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 11)
        }
    }

    func stop2(sender: UIButton){
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 7)
    }
    func close2(sender: UIButton){
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 8)
    }
    func longClose2(sender: UIButton){
        let tempCell = sender.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 9)
    }
    func longlongClose2(sender: UIGestureRecognizer){
         if sender.state == .Began {
        let tempCell = sender.view!.superview?.superview as! UITableViewCell
        let indexPath = self.myCustomTableView.indexPathForCell(tempCell)
        let d = self.data[(indexPath?.row)!] as! Device
        QNTool.openCutain(d, value: 13)
        }
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
