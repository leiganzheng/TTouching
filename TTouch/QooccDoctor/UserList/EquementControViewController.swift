//
//  EquementControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 Lei. All rights reserved.
//

import UIKit
import ReactiveCocoa


class CustomScrollView: UIScrollView {
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, withEvent: event)
        if result is UISlider {
            self.scrollEnabled = false
        }else{
            self.scrollEnabled = true
        }
        return result
    }
}

class EquementControViewController: UIViewController,UIScrollViewDelegate, QNInterceptorProtocol{

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var type:Int?
    var device:Device?
    var unAeraDevice:Device?
    var flag:String?//0：主界面 1：设备管理 2：左边快捷菜单
    var equementType: EquementSign?
    var sixVC:SixPaternViewController?
    var unAeraVC:UnAeraViewController?
    var searchButton:UIButton!
    
    
    private(set) var  pictureScrollView:UIScrollView?
    private(set) var  contentScrollView:CustomScrollView?
    private(set) var  advertisementCurrent:NSInteger = 0
    private(set) var  contentCurrent:NSInteger = 0

    var data: NSMutableArray = NSMutableArray()
    
    let width:CGFloat = screenWidth/5 - 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchData()
        //Right
        searchButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "Manage_Collect_icon"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            let d = self.data[self.contentCurrent] as? Device
            DBManager.shareInstance().updateFav(0, type: (d?.address)!, complete: { (flag) in
                if flag as! Int == 0 {
                    QNTool.showPromptView(NSLocalizedString("失败", tableName: "Localization",comment:"jj"))
                }else {
                    QNTool.showPromptView(NSLocalizedString("成功", tableName: "Localization",comment:"jj"))
                }
            })
            return RACSignal.empty()
            })
        self.navigationItem.rightBarButtonItem = self.type == 100 ? nil :  UIBarButtonItem(customView: searchButton)
        if self.flag == "0" {
            self.title = self.type == 100 ? NSLocalizedString("未分区的区域", tableName: "Localization",comment:"jj") :  self.device?.dev_name
        }
        if self.flag == "2" {
            self.title = self.type == 100 ? NSLocalizedString("未分区的区域", tableName: "Localization",comment:"jj") :  self.device?.dev_name
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Delegate or DataSource
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.pictureScrollView{
            self.advertisementCurrent = NSInteger(scrollView.contentOffset.x / width)
//            self.title = (self.data[self.advertisementCurrent] as? Device)?.dev_name
        }
        if scrollView == self.contentScrollView {
            self.contentCurrent = NSInteger(scrollView.contentOffset.x / screenWidth)
            self.title = (self.data[self.contentCurrent] as? Device)?.dev_name
            let arr = (self.pictureScrollView?.subviews)! as NSArray
            for btn in arr {
                let index = arr.indexOfObject(btn)
                if index == self.contentCurrent {
                    (btn as! UIButton).backgroundColor = defaultBackgroundGrayColor
                }else{
                    (btn as! UIButton).backgroundColor = UIColor.clearColor()
                }
            }
        }
    }

    //MARK: private method

    private func buildUI(){
        //UIScrollView
        self.contentScrollView = CustomScrollView(frame: CGRectMake(0,0, screenWidth, screenHeight-self.headerView.frame.size.height))
        self.contentScrollView!.bounces = false
        self.contentScrollView!.pagingEnabled = true
        self.contentScrollView!.delegate = self
        self.contentScrollView!.showsVerticalScrollIndicator = false
        self.contentScrollView!.showsHorizontalScrollIndicator = false
        self.contentScrollView!.userInteractionEnabled = true
        self.contentView.addSubview(self.contentScrollView!)
        
        
        self.contentScrollView?.backgroundColor = defaultBackgroundColor
        self.contentScrollView?.contentSize = CGSizeMake( screenWidth*CGFloat(self.data.count), 0)
        var index = 0
        for  d in self.data {
            let temp = d as! Device
            index = index+1
            if temp.dev_type == 100{
                self.unAeraVC = UnAeraViewController.CreateFromStoryboard("Main") as? UnAeraViewController
                self.unAeraVC?.flag = self.flag
                self.unAeraVC?.equementType = self.equementType
                self.unAeraVC?.myDevice = temp
                self.unAeraVC?.superVC = self
                self.unAeraVC!.view.frame = CGRectMake(screenWidth * CGFloat(index-1),0 ,screenWidth, ((self.contentScrollView?.frame.size.height)! - 70))
                self.contentScrollView!.addSubview(self.unAeraVC!.view)
                self.addChildViewController( self.unAeraVC!)
            }
            if temp.dev_type == 2 {
                self.sixVC = SixPaternViewController.CreateFromStoryboard("Main") as? SixPaternViewController
                self.sixVC!.flag = self.flag
                self.sixVC?.myDevice = temp
                self.sixVC?.equementType = self.equementType
                self.sixVC?.superVC = self
                
                self.sixVC!.view.frame = CGRectMake(screenWidth * CGFloat(index-1),0 ,screenWidth, ((self.contentScrollView?.frame.size.height)! - 70))
                self.contentScrollView!.addSubview(self.sixVC!.view)
                self.addChildViewController( self.sixVC!)
            }
            
        }
        if self.type == 2 {
            for d in self.data{
                let temp = d as! Device
                if self.device?.address == temp.address {
                    self.contentCurrent = self.data.indexOfObject(d)
                      self.contentScrollView?.setContentOffset(CGPointMake(screenWidth*CGFloat(self.contentCurrent), 0), animated: true)
                }
            }
          
        }
        
    }
    private func buildDataAndUI(){
        //UIScrollView
        self.pictureScrollView = UIScrollView(frame: CGRectMake(0,0, screenWidth, self.headerView.frame.size.height-1))
        self.pictureScrollView!.bounces = false
        self.pictureScrollView!.pagingEnabled = true
        self.pictureScrollView!.delegate = self
        self.pictureScrollView!.showsVerticalScrollIndicator = false
        self.pictureScrollView!.showsHorizontalScrollIndicator = false
        self.pictureScrollView!.userInteractionEnabled = true
        self.view.addSubview(self.pictureScrollView!)
        
        
        self.pictureScrollView?.backgroundColor = defaultBackgroundColor
        self.pictureScrollView?.contentSize = CGSizeMake( width*CGFloat(self.data.count), 0)
        var index = 0
        for  d in self.data {
            index = index+1
           
            let button = UIButton(type: .Custom)
            button.frame = CGRectMake(width * CGFloat(index-1) + 4,4 ,width, ((self.pictureScrollView?.frame.size.height)!-8))
           
            if index == 1 {
                button.backgroundColor = defaultBackgroundGrayColor
            }else{
                 button.backgroundColor = UIColor.clearColor()
            }
            button.setImage(UIImage(data:(d as! Device).icon_url!) , forState: .Normal)
            button.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                let arr = (self.pictureScrollView?.subviews)! as NSArray
                let index = arr.indexOfObject(button)
                self.title = (self.data[index] as? Device)?.dev_name
                self.contentCurrent = index
                for btn in arr {
                    if btn as! NSObject == button {
                        (btn as! UIButton).backgroundColor = defaultBackgroundGrayColor
                    }else{
                        (btn as! UIButton).backgroundColor = UIColor.clearColor()
                    }
                }
                 self.navigationItem.rightBarButtonItem = (self.data[index] as? Device)?.dev_type == 100 ? nil :  UIBarButtonItem(customView: self.searchButton)
                self.contentScrollView?.setContentOffset(CGPointMake(CGFloat(index)*screenWidth, 0), animated: true)
                    return RACSignal.empty()
                
            })

            self.pictureScrollView!.addSubview(button)
          
        }
        let line = UIView()
        line.frame = CGRectMake(0,self.headerView.frame.size.height-1, screenWidth,1)
        line.backgroundColor = defaultLineColor
        self.headerView?.addSubview(line)
   
    }
    func fetchData(){
        self.data = NSMutableArray()
        self.data.removeAllObjects()
        if flag == "0" {
            self.data.addObject(unAeraDevice!)
        }else if flag == "2"{
            let image = UIImageJPEGRepresentation(UIImage(named:"icon_no" )!, 1)
            let noPattern = Device(address: "1000", dev_type: 100, work_status: 31,work_status1: 31,work_status2: 31, dev_name: NSLocalizedString("未分区的区域", tableName: "Localization",comment:"jj"), dev_status: 1, dev_area: "0", belong_area: "", is_favourited: 0, icon_url: image)
            self.data.addObject(noPattern)
        }
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        for (_, element): (Int, Device) in arr.enumerate(){
            if element.dev_type == 2 {//六情景
                self.data.addObject(element)
            }
        }
        self.buildDataAndUI()
        self.buildUI()
    }
}
