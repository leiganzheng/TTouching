//
//  UserListViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 15/7/6.
//  Copyright (c) 2015年 leiganzheng. All rights reserved.
//

import UIKit
import ReactiveCocoa

/**
*  @author leiganzheng, 15-07-06
*
*  //MARK: 用户列表
*/

class UserListViewController: UIViewController, QNInterceptorProtocol, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    private var dataArray: NSMutableArray!
    var data: NSMutableArray = NSMutableArray()
    var flags: NSMutableArray!
    var tempButton:UIButton?
    private var tableViewController: UITableViewController!
    private var leftVC: LeftViewController!
    private var rightVC: RightViewController!
    var myTableView: UITableView!
    var picker: UIImagePickerController?
    
    let Width:CGFloat = 160
    let Y:CGFloat = 64

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = defaultBackgroundColor
        // 让导航栏支持右滑返回功能 
        self.navigationController?.navigationBar.translucent = false
        QNTool.addInteractive(self.navigationController)
        

        self.myTableView = UITableView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.myTableView?.delegate = self
        self.myTableView?.dataSource = self
        self.myTableView?.separatorStyle = UITableViewCellSeparatorStyle.None
        self.myTableView.separatorColor = defaultLineColor
        self.myTableView?.showsVerticalScrollIndicator = false
        self.myTableView?.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]
        self.view.addSubview(self.myTableView!)
        
        self.leftVC = LeftViewController.CreateFromStoryboard("Main") as! LeftViewController
        self.leftVC.view.frame = CGRectMake(-screenWidth,Y, Width,screenHeight)
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.window?.addSubview(self.leftVC.view)
        }

        self.leftVC.bock = {(vc) -> Void in
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
            self.animationWith((self.leftVC)!, x: -screenWidth)
        }
        
        self.rightVC = RightViewController.CreateFromStoryboard("Main") as! RightViewController
        self.rightVC.view.frame = CGRectMake(screenWidth+10,Y, Width,screenHeight)
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.window?.addSubview(self.rightVC.view)
        }
        self.rightVC.bock = {(vc) -> Void in
             self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc as! UIViewController, animated: true)
            self.hidesBottomBarWhenPushed = false
            self.animationWith((self.rightVC)!, x: screenWidth+10)
        }
        
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "navigation_Setup_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
           self?.animationWith((self?.rightVC)!, x: self?.rightVC.view.frame.origin.x == screenWidth-160 ? screenWidth+10 : screenWidth-160)
            return RACSignal.empty()
        })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        //left
        let leftBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton1:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton1.setImage(UIImage(named: "navigation_Menu_icon"), forState: UIControlState.Normal)
        searchButton1.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.animationWith((self?.leftVC)!, x: self?.leftVC.view.frame.origin.x == 0 ? -screenWidth : 0)
            return RACSignal.empty()
            })
        leftBarButton.addSubview(searchButton1)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        self.customNavView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserListViewController.tapAction))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
    
    }
    func tapAction() {
        if self.rightVC != nil && self.rightVC.view.frame.origin.x ==  screenWidth-160{
            self.animationWith((self.rightVC)!, x: self.rightVC.view.frame.origin.x == screenWidth-160 ? screenWidth+10 : screenWidth-160)

        }
        if self.leftVC != nil && self.leftVC.view.frame.origin.x ==  0{
             self.animationWith((self.leftVC)!, x: self.leftVC.view.frame.origin.x == 0 ? -screenWidth : 0)
            
        }
        
    }
    //MARK: 重写手势让tableview能点击
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if NSStringFromClass(touch.view!.classForCoder) == "UITableViewCellContentView"{
            return false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.fetchData()
    }
    
    //MARK:- UITableViewDelegate or UITableViewDataSource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let temp = self.flags[indexPath.row] as! Bool
        return temp == true ? 260 : 72
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "UserTableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UserTableViewCell!
        if cell == nil {
            cell = (NSBundle.mainBundle().loadNibNamed(cellIdentifier, owner: self, options: nil) as NSArray).objectAtIndex(0) as! UserTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
        }
        let d = self.data[indexPath.row] as! Device
        cell.name.text = d.dev_name!
        let logoButton:UIButton = UIButton(frame: CGRectMake(14, 12, 44, 44))
        logoButton.setImage(UIImage(data:d.icon_url!), forState: UIControlState.Normal)
        logoButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            self?.tempButton = input as? UIButton
            let actionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
            actionSheet.addButtonWithTitle("从手机相册选择")
            actionSheet.addButtonWithTitle("拍照")
            actionSheet.rac_buttonClickedSignal().subscribeNext({ (index) -> Void in
                if let indexInt = index as? Int {
                    switch indexInt {
                    case 1, 2:
                        if self!.picker == nil {
                            self!.picker = UIImagePickerController()
                            self!.picker!.delegate = self
                        }
                        self!.picker!.sourceType = (indexInt == 1) ? .SavedPhotosAlbum : .Camera
                        self!.picker!.allowsEditing = true
                        self!.presentViewController(self!.picker!, animated: true, completion: nil)
                    default: break
                    }
                }
            })
            actionSheet.showInView(self!.view)
            return RACSignal.empty()
            })
        cell.contentView.addSubview(logoButton)
        
        let searchButton:UIButton = UIButton(frame: CGRectMake(screenWidth-44, 12, 44, 44))
        searchButton.setImage(UIImage(named: "Manage_Side pull_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
             self?.hidesBottomBarWhenPushed = true
            if d.dev_type != 1 {
                let vc = EquementControViewController.CreateFromStoryboard("Main") as! EquementControViewController
                vc.flag = "0"
                vc.type = d.dev_type
                vc.device = d
                vc.unAeraDevice = (self?.data.lastObject)! as? Device
                self?.navigationController?.pushViewController(vc, animated: true)
                self?.hidesBottomBarWhenPushed = false
            }
            return RACSignal.empty()
            })
        cell.contentView.addSubview(searchButton)   
        searchButton.hidden = d.dev_type == 1
        
        let temp = self.flags[indexPath.row] as! Bool
    
        if temp {
            let v = SubCustomView(frame: CGRectMake(0, 72,screenWidth, 100))
            v.vc = self
             v.tag = indexPath.row + 100
            v.device = d
            v.flag = 0
            let arr = self.fetchScene(d.address!)
            if  arr.count != 0{
                v.data = arr
            }else{
             v.data = ["s1  迎宾模式","s2  主灯气氛","s3  影音欣赏","s4  浪漫情调","s5  全开模式","s6  关闭模式"]
            DBManager.shareInstance().addScene(d, s1: v.data![0] as! String, s2: v.data![1] as! String, s3: v.data![2]as! String ,s4: v.data![3]as! String, s5: v.data![4]as! String, s6: v.data![5]as! String)
            }
            
            cell.contentView.addSubview(v)
            cell.addLine(16, y: 126, width: screenWidth-32, height: 1)
            cell.addLine(16, y: 188, width: screenWidth-32, height: 1)
            cell.addLine(0, y: 258, width: screenWidth, height: 1)
        }else{
            let tempV = cell.contentView.viewWithTag(indexPath.row+100)
            tempV?.removeFromSuperview()
           
        }
        cell.addLine(0, y: 71, width: screenWidth, height: 1)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.myTableView.deselectRowAtIndexPath(indexPath, animated: true)
        let d = self.data[indexPath.row] as! Device
        if d.dev_type != 100 {
            let flag = !(self.flags[indexPath.row] as! Bool)
            self.flags.replaceObjectAtIndex(indexPath.row, withObject: flag)
            
            self.myTableView.reloadData()
        }
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // 存储图片
        let headImage = self.imageWithImageSimple(image, scaledSize: CGSizeMake(image.size.width, image.size.height))
            let headImageData = UIImageJPEGRepresentation(headImage, 0.125)
        //        self.uploadUserFace(headImageData)
        let cell = self.tempButton?.superview?.superview as! UITableViewCell
        let index = self.myTableView.indexPathForCell(cell)
        let d = self.data[index!.row] as! Device
        DBManager.shareInstance().updateIcon(headImageData!, type: d.address!)
        self.tempButton?.setImage(headImage, forState: .Normal)
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.picker?.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK:- private method
    func fetchData(){
        self.dataArray = NSMutableArray()
        self.data.removeAllObjects()
        self.flags = NSMutableArray()
        self.flags.removeAllObjects()
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()

        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type! == 1 || element.dev_type! == 2{
                self.data.addObject(element)
                self.flags.addObject(false)
            }
        }
        if self.data.count != 0 {
            let image = UIImageJPEGRepresentation(UIImage(named:"icon_no" )!, 1)
            let noPattern = Device(address: "1000", dev_type: 100, work_status: 31,work_status1: 31,work_status2: 31, dev_name: "未分区的区域", dev_status: 1, dev_area: "0", belong_area: "", is_favourited: 0, icon_url: image)
            self.data.addObject(noPattern)
            self.flags.addObject(false)
        }
        self.myTableView.reloadData()
        
    }
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
    // 压缩图片
    private func imageWithImageSimple(image: UIImage, scaledSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0,0,scaledSize.width,scaledSize.height))
        let  newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
    func customNavView() {

        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 200, 44))
//        searchButton.setTitle("晴26℃|PM2.5:20", forState: UIControlState.Normal)
        searchButton.setTitle("Hi~Jacky", forState: UIControlState.Normal)
        
//        searchButton.setImage(UIImage(named: "navigation_Setup_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
//            self?.navigationController?.pushViewController(EquementControViewController.CreateFromStoryboard("Main") as! UIViewController, animated: true)
            return RACSignal.empty()
            })

        self.navigationItem.titleView = searchButton
    }
    func animationWith(vc: UIViewController,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        vc.view.frame = CGRectMake(x,Y,Width,screenHeight)
        UIView.commitAnimations()

    }
   
}
