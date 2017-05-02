//
//  SubCustomView.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SubCustomView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    var collectionView:UICollectionView?
    var flag: NSInteger?
    var device:Device?
    var vc:UIViewController?
    var data:NSArray? {
        didSet {
            self.updateLayerFrames()
        }
    }
    var icon:NSArray?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    //实现UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.data!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let identify:String = "Cell"
        let cell:UICollectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier(
            identify, forIndexPath: indexPath)
        let button:UIButton = UIButton(frame:CGRectMake(0, 0, screenWidth/2, 50))
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        if icon?.count>0 {
            button.setImage(UIImage(named: (self.icon![indexPath.row] as? String)!), forState: UIControlState.Normal)
        }
        
        button.setTitle(self.data![indexPath.row] as? String, forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        let status = DBManager.shareInstance().selectStatus(device!.address!)
        if status == 97 && indexPath.row == 0{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 98 && indexPath.row == 1 {
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 99 && indexPath.row == 2{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
        else if status == 100 && indexPath.row == 3{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }
        else if status == 110 && indexPath.row == 4{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 111 && indexPath.row == 5{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 17 && indexPath.row == 0{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 18 && indexPath.row == 1{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 19 && indexPath.row == 2{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 20 && indexPath.row == 3{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 21 && indexPath.row == 4{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }else if status == 31 && indexPath.row == 5{
            button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        }

        cell.contentView.addSubview(button)
        button.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            if self.flag == 1 {return RACSignal.empty()}
            self.sendCommand(indexPath)
            return RACSignal.empty()
        })
        
        
        let gesture = UILongPressGestureRecognizer()
        button.addGestureRecognizer(gesture)
        gesture.rac_gestureSignal().subscribeNext { (obj) in
            let title = NSLocalizedString("修改名字", tableName: "Localization",comment:"jj")
            let cancelButtonTitle = NSLocalizedString("取消", tableName: "Localization",comment:"jj")
            let otherButtonTitle = NSLocalizedString("确定", tableName: "Localization",comment:"jj")
            let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { (action) in
            }
            let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { (action) in
                let textField = (alertController.textFields?.first)! as UITextField
                button.setTitle(textField.text, forState: .Normal)
                
                if textField.text != nil {
                    DBManager.shareInstance().updateSceneName("scene\(indexPath.row+1)",name: textField.text!, addr: (self.device?.address!)!)
                }
                
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.text = button.titleLabel?.text
            }
            alertController.addAction(cancelAction)
            alertController.addAction(otherAction)
            self.vc!.presentViewController(alertController, animated: true) {
                
            }
        }

        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(screenWidth/2-6, 50)
    }

    //实现UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    func sendCommand(indexPath:NSIndexPath){
        if self.device?.dev_type == 1 {
            let command:Int = 36
            let dev_addr = Int(device!.address!)
            let dev_type:Int = device!.dev_type!
            var value = device!.work_status!
            if indexPath.row == 0 {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":17]
                value = 17
                QNTool.openSence(dict)
            }else if(indexPath.row == 1) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":18]
                value = 18
                QNTool.openSence(dict)
            }else if(indexPath.row == 2) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":19]
                value = 19
                QNTool.openSence(dict)
            }else if(indexPath.row == 3) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":20]
                value = 20
                QNTool.openSence(dict)
                
            }else if(indexPath.row == 4) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":21]
                value = 21
                QNTool.openSence(dict)
            }else if(indexPath.row == 5) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":31]
                value = 31
                QNTool.openSence(dict)
            }
            DBManager.shareInstance().updateStatus(value, type: device!.address!)
            if  vc is UserListViewController {
                let temp = vc as! UserListViewController
                temp.myTableView.reloadData()
            }
            if  vc is MainControViewController {
                let temp = vc as! MainControViewController
                temp.myCustomTableView.reloadData()
            }
            if  vc is SixViewController {
                let temp = vc as! SixViewController
                temp.myCustomTableView.reloadData()
            }
            if  vc is CollectionViewController {
                let temp = vc as! CollectionViewController
                temp.myTableView.reloadData()
            }

        }else if(self.device?.dev_type == 2){
            let command:Int = 36
            let dev_addr = Int(device!.address!)
            let dev_type:Int = device!.dev_type!
            var value = device!.work_status!
            if indexPath.row == 0 {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":97]
                value = 97
                QNTool.openSence(dict)
            }else if(indexPath.row == 1) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":98]
                value = 98
                QNTool.openSence(dict)
            }else if(indexPath.row == 2) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":99]
                value = 99
                QNTool.openSence(dict)
            }else if(indexPath.row == 3) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":100]
                value = 100
                QNTool.openSence(dict)
                
            }else if(indexPath.row == 4) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":110]
                value = 110
                QNTool.openSence(dict)
            }else if(indexPath.row == 5) {
                let dict = ["command": command, "dev_addr" : dev_addr!, "dev_type": dev_type, "work_status":111]
                value = 111
                QNTool.openSence(dict)
            }
            DBManager.shareInstance().updateStatus(value, type: device!.address!)
            if  vc is UserListViewController {
                let temp = vc as! UserListViewController
                temp.myTableView.reloadData()
            }
            if  vc is MainControViewController {
                let temp = vc as! MainControViewController
                temp.myCustomTableView.reloadData()
            }
            if  vc is SixViewController {
                let temp = vc as! SixViewController
                temp.myCustomTableView.reloadData()
            }
            if  vc is CollectionViewController {
                let temp = vc as! CollectionViewController
                temp.myTableView.reloadData()
            }
        }

    }
    func updateLayerFrames() {
        let height = CGFloat(self.data!.count/2 == 0 ? self.data!.count/2 : self.data!.count/2 + 1)*50
        self.frame.size.height = height
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRectMake(0, 0, screenWidth, height), collectionViewLayout: layout)
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView!.delegate = self;
        self.collectionView!.dataSource = self;
        
        self.collectionView!.backgroundColor = UIColor.whiteColor()
        self.addSubview(self.collectionView!)
        self.collectionView?.reloadData()
        
    }

}
