//
//  SixViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/29.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SixViewController: UIViewController ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myCustomTableView: UITableView!
    var data: NSMutableArray!
    var sockertManger:SocketManagerTool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return 260
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "cell"
        var cell: SixTableViewCell! = self.myCustomTableView.dequeueReusableCellWithIdentifier(cellId) as? SixTableViewCell
        if cell == nil{
            cell = SixTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        let d = self.data[indexPath.row] as? Device
        let btn = cell.name
        btn.setTitle(d?.dev_name!, forState: .Normal)
//        97:开启情景一; 98:开启情景二; 99:开启情景三; 100:开启情景四;110:场景组内所有设备 ON 状态; 111:场景组内所有设备 OFF 状态; 102:保存当前情景为情景一; 103:保存当前情景为情景二; 104:保存当前情景为情景三; 105:保存当前情景为情景四。
        let command:Int = 36
        let dev_addr = Int(d!.address!)
        let dev_type:Int = d!.dev_type!
         let v = SubCustomView(frame: CGRectMake(0, 72,screenWidth, 100))
        v.backgroundColor = defaultBackgroundGrayColor
        v.vc = self
        v.tag = indexPath.row + 100
        v.device = d
        v.flag = 0
        let arr = self.fetchScene(d!.address!)
        if  arr.count != 0{
            v.data = arr
        }else{
            v.data = [NSLocalizedString("S1 场景一", tableName: "Localization",comment:"jj"),NSLocalizedString("S2 场景二", tableName: "Localization",comment:"jj"),NSLocalizedString("S3 场景三", tableName: "Localization",comment:"jj"),NSLocalizedString("S4 场景四", tableName: "Localization",comment:"jj"),NSLocalizedString("S5 全开模式", tableName: "Localization",comment:"jj"),NSLocalizedString("S6 关闭模式", tableName: "Localization",comment:"jj")]
            DBManager.shareInstance().addScene(d!, s1: v.data![0] as! String, s2: v.data![1] as! String, s3: v.data![2]as! String ,s4: v.data![3]as! String, s5: v.data![4]as! String, s6: v.data![5]as! String)
        }
        
        cell.contentView.addSubview(v)
        cell.addLine(16, y: 126, width: screenWidth-32, height: 1)
        cell.addLine(16, y: 188, width: screenWidth-32, height: 1)
        cell.addLine(0, y: 258, width: screenWidth, height: 1)
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

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myCustomTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    //MARK:- private method
    func fetchScene(addr:String)->NSMutableArray{
        let temp = NSMutableArray()
        temp.removeAllObjects()
        //查
        let arr:Array<String> = DBManager.shareInstance().selectScene(addr)
        
        for (_, element): (Int, String) in arr.enumerate(){
            temp.addObject(element)
        }
        return temp
    }
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type! == 2{
                self.data.addObject(element)
            }
            
            print("Device:\(element.address!)", terminator: "");
        }
        self.myCustomTableView.reloadData()
        
    }
    
    
}