//
//  EquementControViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/6/7.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit
import ReactiveCocoa

class EquementControViewController: UIViewController,UIScrollViewDelegate, QNInterceptorProtocol {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var customTitle:String?
    
    private(set) var  pictureScrollView:UIScrollView?
    private(set) var  advertisementCurrent:NSInteger = 0
    var titles: NSArray = ["灯光","窗帘","动作","空调","监视","保全","音乐","影视"]
    var icons: NSArray = ["Menu_Light_icon2","Menu_Curtain_icon2","Menu_Trigger_icon2","Menu_AirCondition_icon2","Menu_Camera_icon2","Menu_Security_icon2","Menu_Music_icon2","Menu_AV_icon2"]
   
    let width:CGFloat = screenWidth/5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.customTitle
        self.buildDataAndUI()
        //Right
        let rightBarButton = UIView(frame: CGRectMake(0, 0, 40, 40)) //（在外层在包一个View，来缩小点击范围，不然和菜单栏在一起和容易误点）
        let searchButton:UIButton = UIButton(frame: CGRectMake(0, 0, 34, 34))
        searchButton.setImage(UIImage(named: "Manage_Collect_icon1"), forState: UIControlState.Normal)
        searchButton.rac_command = RACCommand(signalBlock: { [weak self](input) -> RACSignal! in
            
            
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
        self.advertisementCurrent = NSInteger(scrollView.contentOffset.x / width)
        self.title = self.titles[self.advertisementCurrent] as? String
        self.contentView.backgroundColor = UIColor(red: (100*CGFloat(self.advertisementCurrent))/255, green: 100/255, blue: 100/255, alpha: 1.0)
    }
    //MARK: private method
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
        self.pictureScrollView?.contentSize = CGSizeMake( width*CGFloat(self.icons.count), 0)
        var index = 0
        for  iconN in self.icons {
            index = index+1
            let button = UIButton(type: .Custom)
            button.frame = CGRectMake(width * CGFloat(index-1),0 ,width, (self.pictureScrollView?.frame.size.height)!)
            button.backgroundColor = UIColor.clearColor()
            button.setImage(UIImage(named:iconN as! String), forState: .Normal)
            self.pictureScrollView!.addSubview(button)
          
        }
        let line = UIView()
        line.frame = CGRectMake(0,self.headerView.frame.size.height-1, screenWidth,1)
        line.backgroundColor = defaultLineColor
        self.headerView?.addSubview(line)
   
    }


}
