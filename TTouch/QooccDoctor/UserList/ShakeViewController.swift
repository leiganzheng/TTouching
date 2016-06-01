//
//  ShakeViewController.swift
//  QooccDoctor
//
//  Created by leiganzheng on 16/5/31.
//  Copyright © 2016年 juxi. All rights reserved.
//

import UIKit

class ShakeViewController: UIViewController {

    @IBOutlet weak var selectButton: UISwitch!
    @IBOutlet weak var zoneView: UIView!
    @IBOutlet weak var zoneBtn: UIButton!
    @IBOutlet weak var screenView: UIView!
    @IBOutlet weak var screenBtn: UIButton!
    
    var zoneSubView: SubCustomView?
    var screenSubView: SubCustomView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QNTool.configViewLayerFrame(zoneView)
        QNTool.configViewLayerFrame(screenView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK:- private method
    func animationWith(v: UIView,x:CGFloat) {
        UIView .beginAnimations("move", context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationDelegate(self)
        v.frame = CGRectMake(x,0, v.frame.size.width,v.frame.size.height)
        UIView.commitAnimations()
        
    }

    @IBAction func zoneAction(sender: AnyObject) {
        if self.zoneSubView == nil {
            self.zoneSubView = SubCustomView(frame: CGRectMake(0,self.zoneView.frame.origin.y+53,screenWidth,100))
            self.zoneSubView?.data = ["客厅","餐厅","书房","主浴","露台","小孩房","主卧房"]
            self .animationWith(self.screenView, x: self.zoneSubView!.frame.origin.y+53+53+100)
            self.view.addSubview(self.zoneSubView!)
        }else{
            self.zoneSubView?.removeFromSuperview()
            self .animationWith(self.screenView, x: self.zoneView.frame.origin.y-53)
        }
        
    }
    @IBAction func screenAction(sender: AnyObject) {
        if self.screenSubView == nil {
            self.screenSubView = SubCustomView(frame: CGRectMake(0,self.screenView.frame.origin.x+53,screenWidth,100))
        }else{
            
        }
    }

}
