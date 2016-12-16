//
//  MannageEquementViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/5.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaAsyncSocket

class MannageEquementViewController: UIViewController  ,QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate{
    
    
    @IBOutlet weak var myTableView: UITableView!
    var data: NSMutableArray = NSMutableArray()
    var icons: NSArray!
    var flags: NSMutableArray!
    var VC: UIViewController!
    
  var sockertManger:SocketManagerTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备管理"
        self.fetchData()
//        self.test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
//        self.test()
//        self.fetchData()
    }

    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count == 0 ? 1 : self.data.count
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
            var cell: UITableViewCell! = self.myTableView.dequeueReusableCellWithIdentifier(cellId)
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
                
            }else{
                while (cell.contentView.subviews.last != nil) {
                    (cell.contentView.subviews.last! as UIView).removeFromSuperview()  //删除并进行重新分配
                }
            }
            let d = self.data[indexPath.row] as! Device
            
            
            let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 120, 44))
            logoButton.setTitle(d.dev_name!, forState: .Normal)
            logoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            logoButton.titleLabel?.textAlignment = .Left
            logoButton.contentHorizontalAlignment = .Left
            logoButton.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0)
            cell.contentView.addSubview(logoButton)
            
            let logoButton1:UIButton = UIButton(frame: CGRectMake(screenWidth/2-22, 12, 44, 44))
            var img:NSData = NSData()
            if d.dev_type == 1 {
                img = UIImageJPEGRepresentation(UIImage(named:"Manage_mastercontrol_icon" )!, 1)!
            }else if(d.dev_type == 100){
                img = d.icon_url!
            }else  {
                img = UIImageJPEGRepresentation(UIImage(named:"Manage_6-scene_icon" )!, 1)!
            }

            logoButton1.setImage(UIImage(data: img), forState: UIControlState.Normal)
            
            cell.contentView.addSubview(logoButton1)
            let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
            searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
            searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                self.selectPatte(d)
                return RACSignal.empty()
            })
            cell.contentView.addSubview(searchButton)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let d = self.data[indexPath.row] as! Device
        self.selectPatte(d)
    }
    //MARK://-Private method
    func  test(){

        let d :NSDictionary = [
            "command": 30,
            "Device Information": [
            [
            "dev_addr": 0,
            "dev_type": 1,
            "work_status": 31,
            "dev_name": "总控设备",
            "dev_status": 1,
            "dev_area": 0
            ],
            [
            "dev_addr": 13014,
            "dev_type": 2,
            "work_status": 111,
            "dev_name": "六场景",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 32881,
            "dev_type": 3,
            "work_status": 0,
            "dev_name": "单回路调光",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 41749,
            "dev_type": 6,
            "work_status": 42,
            "dev_name": "6回路开关",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 13358,
            "dev_type": 5,
            "work_status": 2,
            "dev_name": "3回路开关",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 673,
            "dev_type": 7,
            "work_status": 17,
            "dev_name": "窗帘控制",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 25988,
            "dev_type": 4,
            "work_status": 0,
            "dev_name": "双回路调光",
            "dev_status": 1,
            "dev_area": 13014
            ],
            [
            "dev_addr": 38585,
            "dev_type": 3,
            "work_status": 0,
            "dev_name": "单回路调光",
            "dev_status": 1,
            "dev_area": 0
            ]
            ]
        ]
        
        let devices = d.objectForKey("Device Information") as! NSArray
        let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
        let descs2 = NSArray(objects: typeDesc)
        let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
//        print(array)
        if (array.count == 0) {
            QNTool.showErrorPromptView(nil, error: nil, errorMsg: "获取设备失败")
        }else{
            QNTool.showErrorPromptView(nil, error: nil, errorMsg: "成功")
            self.data.removeAllObjects()
            for tempDict in array {
                self.exeDB(tempDict as! NSDictionary)
            }
            
            self.myTableView.reloadData()
            
        }

    }
    func selectPatte(d:Device){
        if d.dev_type == 1 {//总控
            self.VC = MainControViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 2{//六场景
            self.VC = SixViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
            
        }else if d.dev_type == 3{//单回路调光控制端
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! SigleLightViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 4{//双回路调光控制端
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! DoubleLightViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 5{//三回路开关控制端
            self.VC = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! ThreeOrSixViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 6{//六回路开关控制端
            self.VC = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! ThreeOrSixViewController
            tempVc.flag = true
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 7{//窗帘控制端
            self.VC = CutainControViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! CutainControViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 8{//单回路调光控制端(旧版)
            self.VC = SigleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! SigleLightViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 9{//双回路调光控制端(旧版)
            self.VC = DoubleLightViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! DoubleLightViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 10{//三/六回路开关控制端
            self.VC = ThreeOrSixViewController.CreateFromStoryboard("Main") as! UIViewController
            let tempVc = self.VC as! ThreeOrSixViewController
            tempVc.device = d
            self.navigationController?.pushViewController(tempVc, animated: true)
        }else if d.dev_type == 11{
            self.VC = SixTouchViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
        }else if d.dev_type == 12{//空调
            self.VC = AirViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
            
        }
        else if d.dev_type == 13{//地暖
            self.VC = DNuanViewController.CreateFromStoryboard("Main") as! UIViewController
            self.navigationController?.pushViewController(self.VC, animated: true)
            
        }
    }
    func modifyEqument() {//修改各设备的信息
        let save_dev = [["dev_addr": 43688,"dev_name": "电子双回路调光"],["dev_addr": 22224,"dev_type": 5,"dev_name": "3 回路开关","dev_area": 30785]]
        let dict = ["command": 31,"save_dev": save_dev]
        self.sockertManger.sendMsg(dict, completion: { (result) in
            let d = result as! NSDictionary
            let status = d.objectForKey("status") as! NSNumber
            if (status == 1){
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改成功！")
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "修改失败！")
            }
        })


    }

    func exeDB(tempDic:NSDictionary){
        var dev:Device? = nil
        let addr = tempDic["dev_addr"] as! Int
        let dev_type = tempDic["dev_type"] as! Int
        let work_status = tempDic["work_status"] as! Int
        let name = tempDic["dev_name"] as! String
        let dev_area = tempDic["dev_area"] as! Int
        let dev_status = tempDic["dev_status"] as! Int
        let belong_area = tempDic["dev_area"] as! Int
        let is_favourited = 1
        var image:NSData = NSData()
        if ((tempDic["dev_type"] as? Int) == 1) {//总控
             image = UIImageJPEGRepresentation(UIImage(named:"Room_MasterRoom_icon1" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 2){//六情景
             image = UIImageJPEGRepresentation(UIImage(named:"Room_LivingRoom_icon" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 3){//单回路调光
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
           
        }else if((tempDic["dev_type"] as? Int) == 6){//6回路开关
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_6ch-roads_icon" )!, 1)!
      
        }else if((tempDic["dev_type"] as? Int) == 5){//3回路开关
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_3ch-roads_icon" )!, 1)!
           
        }
        else if((tempDic["dev_type"] as? Int) == 7){//窗帘控制
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Curtains_icon" )!, 1)!

        }else if((tempDic["dev_type"] as? Int) == 4){//双回路调光
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
           
        }
        else if((tempDic["dev_type"] as? Int) == 8){//单回路调光控制端(旧版)
             image = UIImageJPEGRepresentation(UIImage(named:"Manage_ 1ch-Dimmer_icon" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 9){//双回路调光控制端(旧版)
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_2ch-Dimmers_icon" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 10){//三/六回路开关控制端
            image = UIImageJPEGRepresentation(UIImage(named:"Manage_3or6ch-roads_icon" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 11){//干接点
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 12){//空调
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 13){//地暖
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }else if((tempDic["dev_type"] as? Int) == 14){//新风
            image = UIImageJPEGRepresentation(UIImage(named:"" )!, 1)!
            
        }
//        else{
//            image = UIImageJPEGRepresentation(UIImage(named:"icon_no" )!, 1)!
//        }
        dev = Device(address: String(addr), dev_type: dev_type, work_status:work_status , dev_name: name, dev_status: dev_status, dev_area: String(dev_area), belong_area: String(belong_area), is_favourited: is_favourited, icon_url: image)

        if dev != nil {
            self.data.addObject(dev!)
            //创建表
            DBManager.shareInstance().createTable("T_Device")
            //查
            let arr:Array<Device> = DBManager.shareInstance().selectDatas()
            
            //        for (index, element): (Int, Device) in arr.enumerate(){
            //            print("Device:\(element.address!)", terminator: "");
            //        }
//            if arr.count>0 {
//                
//            }else{
                //增：
                DBManager.shareInstance().add(dev!);
//            }
        }
        
    }


    func fetchData(){
        QNTool.showActivityView("获取设备、、、")
        let dict = ["command": 30]
        SocketManagerTool.shareInstance().sendMsg(dict, completion: { (result) in
            QNTool.hiddenActivityView()
            let d = result as! NSDictionary
            let devices = d.objectForKey("Device Information") as! NSArray
            let typeDesc:NSSortDescriptor = NSSortDescriptor(key: "dev_type", ascending: true)
            let descs2 = NSArray(objects: typeDesc)
            let array = devices.sortedArrayUsingDescriptors(descs2 as! [NSSortDescriptor])
            if (array.count == 0) {
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "获取设备失败")
            }else{
                QNTool.showErrorPromptView(nil, error: nil, errorMsg: "成功")
                self.data.removeAllObjects()
                for tempDict in array {
                        self.exeDB(tempDict as! NSDictionary)
                }
                
                self.myTableView.reloadData()
                
            }
        })
    }

}
