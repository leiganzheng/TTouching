//
//  EquementControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class EquementControViewController: UIViewController,UIScrollViewDelegate, QNInterceptorProtocol{

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var customTitle:String?
    var flag:String?//0：主界面 1：设备管理 2：左边快捷菜单
    var equementType: EquementSign?
    var sixVC:SixPaternViewController?
    var unAeraVC:UnAeraViewController?
    
    private(set) var  pictureScrollView:UIScrollView?
    private(set) var  contentScrollView:UIScrollView?
    private(set) var  advertisementCurrent:NSInteger = 0
    private(set) var  contentCurrent:NSInteger = 0

    var data: NSMutableArray = NSMutableArray()
    
    let width:CGFloat = screenWidth/5 - 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.customTitle
        self.fetchData()
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "Manage_Collect_icon1"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
            
            
            return RACSignal.empty()
            })
        rightBarButton.addSubview(searchButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
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
        self.contentScrollView = UIScrollView(frame: CGRectMake(0,0, screenWidth, screenHeight-self.headerView.frame.size.height))
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
                self.unAeraVC!.view.frame = CGRectMake(screenWidth * CGFloat(index-1),0 ,screenWidth, ((self.contentScrollView?.frame.size.height)! - 100))
                self.unAeraVC?.superVC = self
                self.contentScrollView!.addSubview(self.unAeraVC!.view)
            }
            if temp.dev_type == 2 {
                self.sixVC = SixPaternViewController.CreateFromStoryboard("Main") as? SixPaternViewController
                self.sixVC!.flag = self.flag
                self.sixVC?.superVC = self
                self.sixVC!.view.frame = CGRectMake(screenWidth * CGFloat(index-1),0 ,screenWidth, ((self.contentScrollView?.frame.size.height)! - 100))
                self.contentScrollView!.addSubview(self.sixVC!.view)

            }
            
        }

        
    }
    private func buildDataAndUI(){
        //数据
        
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
            button.setImage(UIImage(data: (d as! Device).icon_url!), forState: .Normal)
            button.rac_command = RACCommand(signalBlock: { (input) -> RACSignal! in
                let arr = (self.pictureScrollView?.subviews)! as NSArray
                let index = arr.indexOfObject(button)
                self.title = (self.data[index] as? Device)?.dev_name
                for btn in arr {
                    if btn as! NSObject == button {
                        (btn as! UIButton).backgroundColor = defaultBackgroundGrayColor
                    }else{
                        (btn as! UIButton).backgroundColor = UIColor.clearColor()
                    }
                }

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
        //查
        let arr:Array<Device> = DBManager.shareInstance().selectDatas()
        
        for (_, element): (Int, Device) in arr.enumerate(){
            if  element.dev_type == 2 || element.dev_type == 100 {
                self.data.addObject(element)
            }
            
        }
        self.buildDataAndUI()
        self.buildUI()
        
        
    }


}
